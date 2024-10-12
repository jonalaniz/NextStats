//
//  NextServerManager.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/3/20.
//  Copyright © 2020 Jon Alaniz. All Rights Reserved
//

import UIKit

/// Facilitates the creation, deletion, encoding, and decoding of Nextcloud server objects
class NXServerManager: NSObject {
    /// Returns the singleton `ServerManager` instance.
    public static let shared = NXServerManager()

    weak var delegate: NXServerManagerDelegate?
    let networking = NetworkController.shared

    private var servers: [NextServer] {
        didSet {
            delegate?.serversDidChange(refresh: false)
            saveServers()
        }
    }

    private override init() {
        servers = NXServerManager.getServers()
    }

    private static func getServers() -> [NextServer] {
        guard
            let data = KeychainWrapper.standard.data(forKey: "servers"),
            let savedServers = try? PropertyListDecoder().decode([NextServer].self,
                                                                 from: data)
        else { return [NextServer]() }

        return savedServers
    }

    private func saveServers() {
        do {
            KeychainWrapper.standard.set(try PropertyListEncoder().encode(servers),
                                         forKey: "servers")
        } catch {
            fatalError("Could not encode server data \(error)")
        }
    }

    func add(_ server: NextServer) {
        servers.append(server)
        servers.sort(by: { $0.name < $1.name })
    }

    func remove(_ server: NextServer,
                renaming: Bool = false,
                refresh: Bool) {
        servers.removeAll(where: { $0 == server })
        delegate?.serversDidChange(refresh: refresh)

        if !renaming {
            let path = server.imagePath()
            removeCachedImage(at: path)

            deauthorize(server: server)
        }
    }

    func isEmpty() -> Bool { servers.isEmpty }

    func serverAt(_ index: Int) -> NextServer { return servers[index] }

    func serverCount() -> Int { return servers.count }

    func removeCachedImage(at path: String) {
        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: path) {
            do {
                try fileManager.removeItem(atPath: path)

            } catch {
                print(error.localizedDescription)
            }
        }
    }

    // Create a closure to return the server object ot the StatsViewController
    func rename(server: NextServer, name: String, completion: (NextServer) -> Void) {
        let newServer = NextServer(name: name,
                                   friendlyURL: server.friendlyURL,
                                   URLString: server.URLString,
                                   username: server.username,
                                   password: server.password,
                                   hasCustomLogo: server.hasCustomLogo)
        remove(server, renaming: true, refresh: true)
        add(newServer)
        completion(newServer)
        delegate?.serversDidChange(refresh: true)
    }

    func pingServers() {
        for index in 0..<servers.count {
            pingServer(at: index)
        }
    }

    private func pingServer(at index: Int) {
        let url = URL(string: servers[index].URLString)!
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let request = URLRequest(url: (components?.url)!)
        let task = URLSession(configuration: .default).dataTask(with: request) { _, possibleResponse, possibleError in

            guard  possibleError == nil else {
                DispatchQueue.main.async {
                    self.delegate?.pingedServer(at: index, isOnline: false)
                }
                return
            }

            guard let response = possibleResponse as? HTTPURLResponse else {
                self.setOnlineStatus(at: index, to: false)
                return
            }

            guard (200...299).contains(response.statusCode) else {
                self.setOnlineStatus(at: index, to: false)
                return
            }

            self.setOnlineStatus(at: index, to: true)
        }
        task.resume()
    }

    func deauthorize(server: NextServer) {
        let urlWithEndpoint = URL(string: Endpoint.appPassword.rawValue,
                                  relativeTo: URL(string: server.URLString)!)!
        let config = networking.config(authString: server.authenticationString(),
                                       ocsApiRequest: true)
        Task {
            do {
                _ = try await self.networking.deauthorize(at: urlWithEndpoint,
                                                          config: config)
            } catch {
                print(error)
                DispatchQueue.main.async {
                    self.delegate?.deauthorizationFailed(server: server)
                }
            }
        }
    }

    private func setOnlineStatus(at index: Int, to status: Bool) {
        DispatchQueue.main.async {
            self.delegate?.pingedServer(at: index, isOnline: status)
        }
    }

    // MARK: - Remote Wipe Functions
    func checkWipeStatus(server: NextServer) {
        let urlWithEndpoint = URL(string: Endpoint.wipeCheck.rawValue,
                      relativeTo: URL(string: server.URLString)!)!
        var components = URLComponents(url: urlWithEndpoint,
                                       resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "token", value: server.password)]

        let url = components?.url!

        Task {
            do {
                let data = try await self.networking.neoPost(url: url!)
                let object = try JSONDecoder().decode(WipeObject.self, from: data)
                guard object.wipe == true else {
                    delegate?.unauthorized()
                    return
                }

                DispatchQueue.main.async {
                    self.wipe(server: server)
                }
            } catch {
                print(error)
            }
        }
    }

    private func wipe(server: NextServer) {
        servers.removeAll(where: { $0 == server })
        delegate?.serversDidChange(refresh: true)
        delegate?.serverWiped()

        let path = server.imagePath()
        removeCachedImage(at: path)

        let urlWithEndpoint = URL(string: Endpoint.wipeSuccess.rawValue,
                                  relativeTo: URL(string: server.URLString)!)!
        var components = URLComponents(url: urlWithEndpoint,
                                       resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "token", value: server.password)]

        postWipe(url: components.url!)
    }

    private func postWipe(url: URL) {
        Task {
            do {
                _ = try await self.networking.neoPost(url: url)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

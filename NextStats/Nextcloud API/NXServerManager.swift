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
        var components = URLComponents(string: server.URLString)!
        components.clearQueryAndAppend(endpoint: .appPassword)

        let config = networking.config(authString: server.authenticationString(),
                                       ocsApiRequest: true)
        let url = components.url!

        Task {
            do {
                _ = try await self.networking.deauthorize(at: url, config: config)
            } catch {
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
}

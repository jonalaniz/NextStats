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
    let service = NextcloudService.shared

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
    func renameServer(_ server: NextServer, to name: String, completion: (NextServer) -> Void) {
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
        guard let url = URL(string: servers[index].URLString) else {
            return
        }

        Task {
            do {
                try await service.ping(url)
                self.setOnlineStatus(at: index, to: .online)
            } catch {
                guard let error = error as? APIManagerError else {
                    self.setOnlineStatus(at: index, to: .offline)
                    return
                }

                switch error {
                case .maintenance:
                    self.setOnlineStatus(at: index, to: .maintenance)
                default:
                    self.setOnlineStatus(at: index, to: .offline)
                }
            }
        }
    }

    func deauthorize(server: NextServer) {
        Task {
            do {
                let object = try await service.deauthorize(server: server)
                guard object.meta.statuscode == 200 else {
                    self.delegate?.deauthorizationFailed(server: server)
                    return
                }
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.deauthorizationFailed(server: server)
                }
            }
        }
    }

    private func setOnlineStatus(at index: Int, to status: ServerStatus) {
        DispatchQueue.main.async {
            self.delegate?.pingedServer(at: index, status: status)
        }
    }

    // MARK: - Remote Wipe Functions
    func checkWipeStatus(server: NextServer) {
        Task {
            do {
                let object = try await service.wipeStatus(for: server)
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

        postWipe(server)
    }

    private func postWipe(_ server: NextServer) {
        Task {
            do {
                try await service.postWipe(server)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

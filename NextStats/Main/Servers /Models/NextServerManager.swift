//
//  NextServerManager.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/3/20.
//  Copyright © 2020 Jon Alaniz. All Rights Reserved
//

import Foundation
import UIKit

/// Facilitates the creation, deletion, encoding, and decoding of Nextcloud server objects
class NextServerManager: NSObject {
    /// Returns the singleton `ServerManager` instance.
    public static let shared = NextServerManager()

    weak var delegate: ServerManagerDelegate?
    private var servers: [NextServer] {
        didSet {
            delegate?.serversDidChange(isEmpty: servers.isEmpty)
            saveServers()
        }
    }

    override init() {
        servers = NextServerManager.getServers()
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

    func remove(at index: Int) {
        let fileManager = FileManager.default
        let path = servers[index].imagePath()

        if fileManager.fileExists(atPath: path) {
            do {
                try fileManager.removeItem(atPath: path)

            } catch {
                print(error.localizedDescription)
            }
        }

        servers.remove(at: index)
    }

    func pingServer(at index: Int) {
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

    private func setOnlineStatus(at index: Int, to status: Bool) {
        DispatchQueue.main.async {
            self.delegate?.pingedServer(at: index, isOnline: status)
        }
    }
}

extension NextServerManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? ServerCell
        else { fatalError("DequeueReusableCell failed while casting") }

        cell.accessoryType = .disclosureIndicator
        cell.server = servers[indexPath.row]
        cell.setup()

        return cell
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

extension NextServerManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selected(server: servers[indexPath.row])
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

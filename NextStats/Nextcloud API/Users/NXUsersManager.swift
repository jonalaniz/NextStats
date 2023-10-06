//
//  UserDataManager.swift
//  UserDataManager
//
//  Created by Jon Alaniz on 7/24/21.
//  Copyright © 2021 Jon Alaniz.
//

import Foundation

enum UserDataTypes {
    case user
    case users(Users)
}

/// Facilitates the fetching, creation, deletion, and editing of Nextcloud Users
class NXUsersManager {
    /// Returns singleton instance of `UserDataManager`
    static let shared = NXUsersManager()

    weak var delegate: NXDataManagerDelegate?
    private let networking = NetworkController.shared
    private var userIDs = [String]()
    private var server: NextServer! {
        didSet { userIDs.removeAll() }
    }

    private init() {}

    func fetchUsersData() {
        delegate?.stateDidChange(.fetchingData)

        let url = URL(string: server.URLString)!
        let authString = server.authenticationString()

        Task {
            do {
                let data = try await networking.fetchData(url: url, authentication: authString)
                // Here we work with our captured data object
                guard let decodedData: Users = self.decode(data) else {
                    throw FetchError.invalidData
                }

                decodedData.data.users.element.forEach { self.userIDs.append($0) }
                DispatchQueue.main.async { self.delegate?.stateDidChange(.dataCaptured) }
            } catch {
                print(error)
            }
        }

    }

    func fetch(user: String) {
        let url = URL(string: server.URLString)!
        let authString = server.authenticationString()
        let request = networking.request(url: url, with: .userEndpoint, appending: user)
        let configuration = networking.config(authString: authString, ocsApiRequest: true)

        Task {
            do {
                let data = try await networking.fetchData(with: request, config: configuration)
                await print(String(data: data, encoding: .utf8))
            } catch {
                print(error)
            }
        }
    }

    private func decode<T: Codable>(_ data: Data) -> T? {
        let decoder = XMLDecoder()

        do {
            let loaded = try decoder.decode(T.self, from: data)
            return loaded
        } catch {
            print(error)
        }

        return nil
    }

    private func dateString(from milliseconds: Int?) -> String {
        guard milliseconds != nil else { return "N/A" }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd,yyyy"

        let seconds = milliseconds! / 1000
        let date = Date(timeIntervalSince1970: TimeInterval(seconds))

        return dateFormatter.string(from: date)
    }
}

/// TableView Helper Methods
extension NXUsersManager {
    func setServer(server: NextServer) {
        self.server = server
    }

    func userID(_ index: Int) -> String {
        return userIDs[index]
    }

    func usersCount() -> Int {
        return userIDs.count
    }
}

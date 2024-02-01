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
    private var users = [User]()
    private var server: NextServer! {
        didSet {
            userIDs.removeAll()
            users.removeAll()
        }
    }

    private init() {}

    func fetchUsersData() {
        delegate?.stateDidChange(.fetchingData)

        let url = URL(string: server.URLString)!
        let authString = server.authenticationString()

        Task {
            do {
                let data = try await networking.fetchUsers(url: url, authentication: authString)

                // Here we work with our captured data object
                guard let decodedData: Users = self.decode(data) else {
                    throw FetchError.invalidData
                }

                decodedData.data.users.element.forEach { self.userIDs.append($0) }

                let configuration = networking.config(authString: authString, ocsApiRequest: true)

                for userID in userIDs {
                    let request = networking.request(url: url, with: .userEndpoint, appending: userID)
                    let data = try await networking.fetchData(with: request, config: configuration)

                    guard let decodedUser: User = self.decode(data) else {
                        throw FetchError.invalidData
                    }

                    users.append(decodedUser)
                }

                DispatchQueue.main.async {
                    self.delegate?.stateDidChange(.dataCaptured)
                }
            } catch {
                print(error)
            }
        }
    }

//    private func getUserImage(userID: String) 

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

    func user(id: String) -> User {
        return users.first(where: { $0.data.id == id })!
    }

    func userID(_ index: Int) -> String {
        return userIDs[index]
    }

    func usersCount() -> Int {
        return userIDs.count
    }

    func userCellModel(_ index: Int) -> UserCellModel {
        let userData = users[index].data

        return UserCellModel(userID: userData.id,
                             displayName: userData.displayname ?? "N/A",
                             email: userData.email ?? "N/A",
                             enabled: userData.enabled)
    }
}

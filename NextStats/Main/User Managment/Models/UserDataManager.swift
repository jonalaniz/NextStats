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
class UserDataManager {
    /// Returns singleton instance of `UserDataManager`
    static let shared = UserDataManager()

    weak var delegate: DataManagerDelegate?
    private let networkController = NetworkController.shared
    private var userIDs = [String]()
    private var server: NextServer! {
        didSet { userIDs.removeAll() }
    }

    private init() {}

    /// Network request for list of users. Can be used for search.
    func fetchUsers() {
        let url = URL(string: server.URLString)!
        let authorization = server.authenticationString()
        let request = networkController.request(url: url, with:
                                                        .usersEndpoint)
        let configuration = networkController.configuration(authorizaton: authorization,
                                                            ocsApiRequest: true)

        networkController.fetchData(with: request,
                                    using: configuration) { (result: Result<Data, FetchError>) in
            switch result {
            case .success(let data):
                // TODO: Change this to a guard statement and add error handling
                if let decodedData: Users = self.decode(data) {
                    decodedData.data.users.element.forEach { self.userIDs.append($0) }
                    DispatchQueue.main.async { self.delegate?.dataUpdated() }
                }
            case .failure(let failure):
                print(failure)
            }
        }
    }

    func fetchUser(named user: String) {
        let url = URL(string: server.URLString)!
        let authorizationString = server.authenticationString()
        let request = networkController.request(url: url,
                                                with: .userEndpoint,
                                                appending: user)
        let configuration = networkController.configuration(authorizaton: authorizationString,
                                                            ocsApiRequest: true)

        networkController.fetchData(with: request, using: configuration) { (result: Result<Data, FetchError>) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let data):
                // TODO: Change this to a guard statement and add error handling
                if let usersData: User = self.decode(data) {
                    print(usersData)
                }
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
}

/// TableView Helper Methods
extension UserDataManager {
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

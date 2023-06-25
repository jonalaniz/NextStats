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

    weak var delegate: DataManagerDelegate?
    private let networkController = NetworkController.shared
    private var userIDs = [String]()
    private var server: NextServer! {
        didSet { userIDs.removeAll() }
    }

    private init() {}

    func fetchUsersData() {
        // Notify delagate
        delegate?.didBeginFetchingData()

        let url = URL(string: server.URLString)!
        let authString = server.authenticationString()

        Task {
            do {
                let data = try await networkController.fetchData(url: url, authentication: authString)
                // Here we work with our captured data object
                guard let decodedData: Users = self.decode(data) else {
                    throw FetchError.invalidData
                }

                decodedData.data.users.element.forEach { self.userIDs.append($0) }
                DispatchQueue.main.async { self.delegate?.dataUpdated() }
            } catch {
                print(error)
            }
        }

    }
    /// Network request for list of users. Can be used for search.
//    func fetchUsers() {
//        let url = URL(string: server.URLString)!
//        let authorization = server.authenticationString()
//        let request = networkController.request(url: url, with:
//                                                        .usersEndpoint)
//        let configuration = networkController.configuration(authorizaton: authorization,
//                                                            ocsApiRequest: true)
//
//        networkController.fetchData(with: request,
//                                    using: configuration) { (result: Result<Data, FetchError>) in
//            switch result {
//            case .success(let data):
//                // TODO: Change this to a guard statement and add error handling
//                if let decodedData: Users = self.decode(data) {
//                    decodedData.data.users.element.forEach { self.userIDs.append($0) }
//                    DispatchQueue.main.async { self.delegate?.dataUpdated() }
//                }
//            case .failure(let failure):
//                print(failure)
//            }
//        }
//    }

    func fetchUser(named user: String) {
        let url = URL(string: server.URLString)!
        let authorizationString = server.authenticationString()
        let request = networkController.request(url: url,
                                                with: .userEndpoint,
                                                appending: user)
        let configuration = networkController.config(authString: authorizationString,
                                                     ocsApiRequest: true)

        networkController.fetchData(with: request, using: configuration) { (result: Result<Data, FetchError>) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let data):
                // TODO: Change this to a guard statement and add error handling
                let string = String(data: data, encoding: .utf8)
                print(string)
                if let usersData: User = self.decode(data) {
                    print(usersData)
                    print(self.dateString(from: usersData.data.lastLogin))
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

//
//  UserDataManager.swift
//  UserDataManager
//
//  Created by Jon Alaniz on 7/24/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import Foundation

/// Facilitates the fetching, creation, deletion, and editing of Nextcloud Users
class UserDataManager {
    /// Returns singleton instance of `UserDataManager`
    static let shared = UserDataManager()

    weak var delegate: UsersDelegate?
    let networkController = NetworkController.shared
    var userIDs = [String]()
    var server: NextServer! {
        didSet { userIDs.removeAll() }
    }

    private init() {}

    func fetchUsers() {
        let url = URL(string: server.URLString)!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.query = nil
        components.path = Paths.usersEndpoint

        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "Authorization": server.authenticationString(),
            "OCS-APIRequest": "true"
        ]

        let request = URLRequest(url: components.url!)

        networkController.fetchData(with: request,
                                    using: configuration) { (result: Result<Data, FetchError>) in
            switch result {
            case .success(let data):
                self.decodeUserData(with: data)
            case .failure(let failure):
                print(failure)
            }
        }
    }

    private func decodeUserData(with data: Data) {
        let decoder = XMLDecoder()
        do {
            let xml = try decoder.decode(Users.self, from: data)
            xml.data.users.element.forEach { userIDs.append($0) }

            DispatchQueue.main.async { self.delegate?.didRecieveUsers() }
        } catch {
            print(error)
        }
    }
}

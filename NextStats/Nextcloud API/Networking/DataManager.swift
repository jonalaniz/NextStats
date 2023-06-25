//
//  DataManager.swift
//  NextStats
//
//  Created by Jon Alaniz on 10/18/22.
//  Copyright © 2022 Jon Alaniz. All rights reserved.
//

import Foundation

protocol ErrorHandler: AnyObject {
    func handle(error type: FetchError)
}

enum FetchError: Error {
    case error(String) // Sends error.localizedDescription
    case invalidData
    case invalidURL
    case missingResponse
    case unexpectedResponse(HTTPURLResponse)

    var title: String {
        switch self {
        case .error(_): return .localized(.errorTitle)
        case .invalidData: return .localized(.invalidData)
        case .invalidURL: return .localized(.networkError)
        case .missingResponse: return .localized(.missingResponse)
        case .unexpectedResponse(_): return .localized(.unauthorized)
        }
    }

    var description: String {
        switch self {
        case .error(let description): return description
        case .invalidData: return .localized(.invalidDataDescription)
        case .invalidURL: return .localized(.networkError)
        case .missingResponse: return .localized(.missingResponseDescription)
        case .unexpectedResponse(_): return .localized(.unexpectedResponse)
        }
    }
}

/// DataManager struct manages pulling json data from URLs
@available (*, deprecated, message: "Move to `NetworkController` using async/await")
class DataManager {
    /// Returns the singleton `DataManager` instance
    public static let shared = DataManager()

    private init() { }

    /// Reusable data call method
    static func loadDataFromURL(with request: URLRequest,
                                config: URLSessionConfiguration = .default,
                                completion: @escaping (_ data: Data?, _ error: FetchError?) -> Void) {
        let config = config
        var request = request

        config.allowsCellularAccess = true
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        config.httpMaximumConnectionsPerHost = 1
        request.setValue("NextStats for iOS", forHTTPHeaderField: "User-Agent")

        let session = URLSession(configuration: config)

        let loadDataTask = session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(nil, .error(error!.localizedDescription))
                return
            }

            guard let response = response as? HTTPURLResponse else {
                completion(nil, .missingResponse)
                return
            }

            guard 200...299 ~= response.statusCode else {
                completion(nil, .unexpectedResponse(response))
                return
            }

            guard let data = data else {
                completion(nil, .invalidData)
                return
            }

            // Success, return the data that was loaded
            completion(data, nil)
        }

        loadDataTask.resume()
    }
}

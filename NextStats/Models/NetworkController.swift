//
//  NetworkController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/8/21.
//  Copyright © 2021 Jon Alaniz
//

import Foundation

enum FetchError: Error {
    case invalidData
    case missingResponse
    case network(Error)
    case unexpectedResponse(Int)

    var title: String {
        switch self {
        case .invalidData: return LocalizedKeys.invalidData
        case .missingResponse: return LocalizedKeys.missingResponse
        case .network(_): return LocalizedKeys.networkError
        case .unexpectedResponse(_): return LocalizedKeys.unauthorized
        }
    }

    var description: String {
        switch self {
        case .invalidData: return LocalizedKeys.invalidDataDescription
        case .missingResponse: return LocalizedKeys.missingResponseDescription
        case .network(_): return LocalizedKeys.networkError
        case .unexpectedResponse(_): return LocalizedKeys.unexpectedResponse
        }
    }
}

enum FetchType {
    case statistics
    case authResponse
    case poll
    case serverAuthenticationInfo
}

class NetworkController {
    /// Returns the singleton `NetworkController` instance
    public static let shared = NetworkController()

    private init() { }

    /// Generic network fetch
    func fetchData(with request: URLRequest,
                   using config: URLSessionConfiguration = .default,
                   completion: @escaping (Result<Data, FetchError>) -> Void) {

        var request = request
        request.setValue("NextStats for iOS", forHTTPHeaderField: "User-Agent")

        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (possibleData, possibleResponse, possibleError) in

            guard possibleError == nil else {
                completion(.failure(.network(possibleError!)))
                return
            }

            guard let response = possibleResponse as? HTTPURLResponse else {
                completion(.failure(.missingResponse))
                return
            }

            guard (200...299).contains(response.statusCode) else {
                completion(.failure(.unexpectedResponse(response.statusCode)))
                return
            }

            guard let receivedData = possibleData else {
                completion(.failure(.invalidData))
                return
            }

            completion(.success(receivedData))
        }
        task.resume()
    }
}

//
//  NetworkController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/8/21.
//  Copyright © 2021 Jon Alaniz.

import Foundation

enum FetchError: Error {
    case invalidData
    case missingResponse
    case network(Error)
    case unexpectedResponse(Int)

    var title: String {
        switch self {
        case .invalidData: return .localized(.invalidData)
        case .missingResponse: return .localized(.missingResponse)
        case .network(_): return .localized(.networkError)
        case .unexpectedResponse(_): return .localized(.unauthorized)
        }
    }

    var description: String {
        switch self {
        case .invalidData: return .localized(.invalidDataDescription)
        case .missingResponse: return .localized(.missingResponseDescription)
        case .network(_): return .localized(.networkError)
        case .unexpectedResponse(_): return .localized(.unexpectedResponse)
        }
    }
}

class NetworkController {
    /// Returns the singleton `NetworkController` instance
    public static let shared = NetworkController()

    private init() { }

    /// Generic network fetch
    func fetchData(with request: URLRequest,
                   using config: URLSessionConfiguration = .default,
                   completion: @escaping (Result<Data, FetchError>) -> Void) {
        config.timeoutIntervalForRequest = 15

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

    func request(url: URL, with endpoint: Endpoints, appending user: String? = nil) -> URLRequest {
        let url = url
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.clearQueryAndAppend(endpoint: endpoint)

        if let username = user { components.path.append(contentsOf: username) }

        return URLRequest(url: components.url!)
    }

    func configuration(authorizaton: String? = nil, ocsApiRequest: Bool = false) -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default

        guard let authorizationString = authorizaton else {
            return configuration
        }

        var headers = ["Authorization": authorizationString]

        if ocsApiRequest == true {
            // OCS-APIRequest is needed for legacy (XML based) requests
            headers.updateValue("true", forKey: "OCS-APIRequest")
        }

        configuration.httpAdditionalHeaders = headers

        return configuration
    }
}

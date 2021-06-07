//
//  NetworkController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/8/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import Foundation

enum FetchError: Error {
    case network(Error)
    case missingResponse
    case unexpectedResponse(Int)
    case invalidData
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
    
    /// Generic network fetch
    func fetchData(with request: URLRequest, using config: URLSessionConfiguration = .default, completion: @escaping (Result<Data, FetchError>) -> Void) {
        let request = request
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

//
//  DataManager.swift
//  NextStats
//
//  Created by Jon Alaniz on 10/18/22.
//  Copyright © 2022 Jon Alaniz. All rights reserved.
//

import Foundation

protocol ErrorHandler: AnyObject {
    func handle(error type: ErrorType)
}

enum ErrorType {
    case invalidURL
    // This error being sent should be Error.loaclized description
    case error(String)
    case missingResponse
    case unexpectedResponse(HTTPURLResponse)
    case invalidData
}

/// DataManager struct manages pulling json data from URLs
class DataManager {
    /// Returns the singleton `DataManager` instance
    public static let shared = DataManager()

    private init() { }

    /// Requests Authentication Data using Nextcloud Login Flow V2
    func getAuthenticationDataWithSuccess(urlString: String,
                                          success: @escaping ((_ data: Data?, _ error: ErrorType?) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let url = URL(string: urlString) else {
                // The URL was invalid, so pass the error to the completion handler
                success(nil, .invalidURL)
                return
            }

            // Append Login Flow V2 endpoint and create request
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            components.clearQueryAndAppend(endpoint: .loginEndpoint)

            var request = URLRequest(url: components.url!)
            request.httpMethod = "POST"

            DataManager.loadDataFromURL(with: request) { data, errorType  in
                // Pass the data from `loadDataFromURL` to completion handler
                success(data, errorType)
            }
        }
    }

    /// Requests Nextcloud Server Data Object
    func getServerStatisticsDataWithSuccess(urlString: String,
                                            config: URLSessionConfiguration,
                                            success: @escaping((_ data: Data?, _ error: ErrorType?) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let url = URL(string: urlString) else {
                // Thr URL was invalid
                success(nil, .invalidURL)
                return
            }

            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            components.clearQueryAndAppend(endpoint: .statEndpoint)

            let request = URLRequest(url: components.url!)

            DataManager.loadDataFromURL(with: request, config: config) { data, errorType in
                success(data, errorType)
            }
        }
    }

    /// Reusable data call method
    static func loadDataFromURL(with request: URLRequest,
                                config: URLSessionConfiguration = .default,
                                completion: @escaping (_ data: Data?, _ error: ErrorType?) -> Void) {
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

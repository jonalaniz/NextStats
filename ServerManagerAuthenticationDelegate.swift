//
//  ServerManagerAuthenticationDelegate.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/17/21.
//  Copyright © 2021 Jon Alaniz
//

import Foundation

/// String descriptions for various authentication errors.
@objc public enum ServerManagerAuthenticationError: Int {
    case notValidHost
    case serverNotFound
    case failedToSerializeResponse
    case authorizationDataMissing

    public var description: String {
        switch self {
        case .notValidHost: return LocalizedKeys.notValidhost
        case .serverNotFound: return LocalizedKeys.serverNotFound
        case .failedToSerializeResponse: return LocalizedKeys.failedToSerializeResponse
        case .authorizationDataMissing: return LocalizedKeys.authorizationDataMissing
        }
    }
}

/// Functions called by ServerManager pertaining to authenitcation status
@objc public protocol ServerManagerAuthenticationDelegate {
    /// Called when server is successfully added to the manager
    func didCaptureCredentials()

    /// Called when login url and associated authorization data is recieved.
    func didRecieve(loginURL: String)

    /// Called when ServerManager is unable to get authorization data from server. Returns error information.
    func failedToGetCredentials(withError error: ServerManagerAuthenticationError)

    /// Called when networkManager finds network error, passes localized description.
    func networkError(error: String)
}

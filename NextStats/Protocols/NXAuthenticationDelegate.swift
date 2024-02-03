//
//  ServerManagerAuthenticationDelegate.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/17/21.
//  Copyright © 2021 Jon Alaniz.

import Foundation

/// String descriptions for various authentication errors.
enum ServerManagerAuthenticationError: Int {
    case notValidHost
    case serverNotFound
    case failedToSerializeResponse
    case authorizationDataMissing

    public var description: String {
        switch self {
        case .notValidHost: return .localized(.notValidhost)
        case .serverNotFound: return .localized(.serverNotFound)
        case .failedToSerializeResponse: return .localized(.failedToSerializeResponse)
        case .authorizationDataMissing: return .localized(.authorizationDataMissing)
        }
    }
}

/// Functions called by ServerManager pertaining to authenitcation status
protocol NXAuthenticationDelegate: AnyObject {
    /// Called when server is successfully added to the manager
    func didCapture(server: NextServer)

    /// Called when login url and associated authorization data is recieved.
    func didRecieve(loginURL: String)

    /// Called when ServerManager is unable to get authorization data from server. Returns error information.
    func failedToGetCredentials(withError error: ServerManagerAuthenticationError)

    /// Called when networkManager finds network error, passes localized description.
    func networkError(error: String)
}

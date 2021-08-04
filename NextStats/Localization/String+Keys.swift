//
//  LocalizedKeys.swift
//  NextStats
//
//  Created by Jon Alaniz on 7/3/21.
//  Copyright © 2021 Jon Alaniz. All Rights Reserved.
//

import Foundation

enum LocalizedKeys: String {
    case addScreenTitle = "add.screen.title"
    case addScreenNickname = "add.screen.nickname"
    case addScreenUrl = "add.screen.url"
    case addScreenLabel = "add.screen.label"
    case addScreenStatusLabel = "add.screen.statuslabel"
    case addScreenConnect = "add.screen.connect"

    case serverAddButton = "server.screen.add"

    case statsScreenFetchingData = "stats.screen.fetchingData"
    case statsScreenSelectLabel = "stats.screen.selectServerLabel"

    case infoScreenDevHeader = "info.screen.development.header"
    case infoScreenDevTitle = "info.screen.development.developer"
    case infoScreenLocaleHeader = "info.screen.localization.header"
    case infoScreenLocaleFrench = "info.screen.localization.french"
    case infoScreenLocaleGerman = "info.screen.localization.german"
    case infoScreenLocaleTurkish = "info.screen.localization.turkish"
    case infoScreenLicenseHeader = "info.screen.licenses.header"
    case infoScreenLicenseDescription = "info.screen.licenses.description"
    case infoScreenSupportHeader = "info.screen.support.header"
    case infoScreenSupportDescription = "info.screen.support.description"

    case iapThank = "iap.thankyou"
    case iapThankDescription = "iap.thankyou.description"

    case invalidData = "error.invaliddata"
    case invalidDataDescription = "error.invaliddata.description"
    case missingResponse = "error.missingresponse"
    case missingResponseDescription = "error.missingresponse.description"
    case networkError = "error.networkerror"
    case unauthorized = "error.unauthorized"
    case unauthorizedDescription = "error.unauthorized.description"
    case unexpectedResponse = "error.unexpectedresponse"

    case notValidhost = "error.notValidHost"
    case serverNotFound = "error.serverNotFound"
    case failedToSerializeResponse = "error.failedToSerializeResponse"
    case authorizationDataMissing = "error.authorizationDataMissing"

    case missingData = "error.missingData"
    case unableToParseData = "error.unableToParseData"
}

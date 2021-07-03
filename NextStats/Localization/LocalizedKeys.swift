//
//  LocalizedKeys.swift
//  NextStats
//
//  Created by Jon Alaniz on 7/3/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import Foundation

enum LocalizedKeys {
    static let addScreenTitle = "add.screen.title".localized()
    static let addScreenNickname = "add.screen.nickname".localized()
    static let addScreenUrl = "add.screen.url".localized()
    static let addScreenLabel = "add.screen.label".localized()
    static let addScreenStatusLabel = "add.screen.statuslabel".localized()
    static let addScreenConnect = "add.screen.connect".localized()

    static let serverAddButton = "server.screen.add".localized()

    static let infoScreenDevHeader = "info.screen.development.header".localized()
    static let infoScreenDevTitle = "info.screen.development.developer".localized()
    static let infoScreenLocaleHeader = "info.screen.localization.header".localized()
    static let infoScreenLocaleFrench = "info.screen.localization.french".localized()
    static let infoScreenLocaleGerman = "info.screen.localization.german".localized()
    static let infoScreenLocaleTurkish = "info.screen.localization.turkish".localized()
    static let infoScreenLicenseHeader = "info.screen.licenses.header".localized()
    static let infoScreenLicenseDescription = "info.screen.licenses.description".localized()
    static let infoScreenSupportHeader = "info.screen.support.header".localized()
    static let infoScreenSupportDescription = "info.screen.support.description".localized()

    static let iapThank = "iap.thankyou".localized()
    static let iapThankDescription = "iap.thankyou.description".localized()

    static let errorInvalidData = "error.invaliddata".localized()
    static let errorInvalidDataDescription = "error.invaliddata.description".localized()
    static let errorMissingResponse = "error.missingresponse".localized()
    static let errorMissingResponseDescription = "error.missingresponse.description".localized()
    static let errorNetwork = "error.networkerror".localized()
    static let errorUnauthorized = "error.unauthorized".localized()
    static let errorUnauthorizedDescription = "error.unauthorized.description".localized()
    static let errorUnexpectedResponse = "error.unexpectedresponse".localized()
}

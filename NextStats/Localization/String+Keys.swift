//
//  LocalizedKeys.swift
//  NextStats
//
//  Created by Jon Alaniz on 7/3/21.
//  Copyright © 2021 Jon Alaniz.
//

// swiftlint:disable identifier_name
import Foundation

enum LocalizedKeys: String {
    // MARK: - Add Server View
    case addScreenTitle = "add.screen.title"
    case addScreenNickname = "add.screen.nickname"
    case addScreenUrl = "add.screen.url"
    case addScreenLabel = "add.screen.label"
    case addScreenStatusLabel = "add.screen.statuslabel"
    case addScreenConnect = "add.screen.connect"

    // MARK: - Server Form View
    case serverFormServer = "server.form.server"
    case serverFromMyServer = "server.form.myserver"
    case serverFormEnterAddress = "server.form.enterAddress"
    case serverFormEnterValidAddress = "server.form.enterValidAddress"

    // MARK: - Server View
    case serverAddButton = "server.screen.add"

    // MARK: - No Servers View
    case noServersLabel = "noserver.view.label"

    // MARK: - Statistics View
    case statsScreenFetchingData = "stats.screen.fetchingData"
    case statsScreenSelectLabel = "stats.screen.selectServerLabel"

    // MARK: - Statistics View.Actions
    case statsActionRename = "stats.action.rename"
    case statsActionRenameTitle = "stats.action.rename.title"
    case statsActionDelete = "stats.action.delete"
    case statsActionDeleteTitle = "stats.action.delete.title"
    case statsActionDeleteMessage = "stats.action.delete.message"
    case statsActionCancel = "stats.action.cancel"
    case statsActionContinue = "stats.action.continue"

    // MARK: - ServerHeaderView

    /* Text = "Visit Server" */
    case serverHeaderVisit = "server.header.visit"

    // MARK: - Info View
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

    // MARK: - UserCell
    case enabled = "usercell.enabled"
    case disabled = "usercell.disabled"

    // MARK: - Users
    case users = "users"
    case usersEmail = "users.email"
    case usersNoEmail = "users.noemail"
    case quota = "users.quota"
    case quotaUnlimited = "users.quotaunlimited"
    case status = "users.status"
    case capabilities = "users.capabilities"
    case language = "users.language"
    case lastLogin = "users.lastLogin"
    case location = "users.location"
    case backend = "users.backend"
    case setDisplayName = "users.setDisplayName"
    case setPassword = "users.setPassword"
    case no = "users.no"

    // MARK: - Users.Popover
    case enable = "users.enable"
    case disable = "users.disable"
    case delete = "users.delete"
    case deleteUser = "users.deleteUser"
    case deleteUserMessage = "users.deleteUserMessage"

    // MARK: - New Users
    case newUser = "newusers.newuser"
    case usernameRequired = "newusers.userNameRequired"
    case displayName = "newusers.displayName"
    case password = "newusers.password"
    case email = "newuser.email"
    case noGroups = "newuser.noGroups"
    case selectGroups = "Select groups"
    case requiredFields = "newuser.requiredFields"
    case groups = "newuser.groups"
    case setSubAdmin = "newuser.setSubAdmin"

    // MARK: - SelectionViewController
    case adminOf = "selection.adminOf"

    // MARK: - Errors.StatusLabel
    case errorTitle = "error.title"
    case invalidData = "error.invaliddata"
    case invalidDataDescription = "error.invaliddata.description"
    case missingResponse = "error.missingresponse"
    case missingResponseDescription = "error.missingresponse.description"
    case networkError = "error.networkerror"
    case unauthorized = "error.unauthorized"
    case unauthorizedDescription = "error.unauthorized.description"
    case unexpectedResponse = "error.unexpectedresponse"

    // MARK: - Errors.ServerManagerAuthenticationError
    case notValidhost = "error.notValidHost"
    case serverNotFound = "error.serverNotFound"
    case failedToSerializeResponse = "error.failedToSerializeResponse"
    case authorizationDataMissing = "error.authorizationDataMissing"

    // MARK: - Errors.DataManagerError
    case missingData = "error.missingData"
    case unableToParseData = "error.unableToParseData"

    // MARK: - Errors.NXErrors
    case internalError = "error.internal"
    case unableToEncodeData = "error.unableToEncodeData"
    case unableToRemove = "error.unableToRemove"
    case unableToRemoveMessage = "error.unableToRemoveMessage"
}

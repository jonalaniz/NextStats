//
//  NewUserStatusCode.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/28/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//
//        100 - successful
//        101 - invalid input data
//        102 - username already exists
//        103 - unknown error occurred whilst adding the user
//        104 - group does not exist
//        105 - insufficient privileges for group
//        106 - no group specified (required for subadmins)
//        107 - all errors that contain a hint
//        108 - password and email empty. Must set password or an email
//        109 - invitation email cannot be send

import Foundation

enum NewUserStatusCode: Int {
    case successful = 100
    case invalidData = 101
    case usernameAlreadyExists = 102
    case unknownError = 103
    case groupDoesNotExist = 104
    case insufficientPrivilegesForGroup = 105
    case noGroupSpecified = 106
    case hint = 107
    case requirementNotMeant = 108
    case inviteCannotBeSent = 109
}

//
//  ISO8601DateFormatter.swift
//  XMLParsing
//
//  Created by Shawn Moore on 11/21/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

// NOTE: This value is implicitly lazy and _must_ be
// lazy. We're compiled against the latest SDK (w/
// ISO8601DateFormatter), but linked against whichever
// Foundation the user has. ISO8601DateFormatter might
// not exist, so we better not hit this code path on an
// older OS.
@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
// swiftlint:disable:next identifier_name
internal var _iso8601Formatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = .withInternetDateTime
    return formatter
}()

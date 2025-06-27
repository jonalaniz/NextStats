//
//  ActivityRow.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/26/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import Foundation

/// Represents the different time ranges for displaying active user statistics.
enum ActivityRow: Int, TitledSection {
    /// Active users in the last 5 minutes.
    case last5

    /// Active users in the last hour.
    case lastHour

    /// Active users in the last 24 hours.
    case lastDay

    /// Total number of users.
    case total

    /// The display title for the row.
    ///
    /// This string is used in the table view cell to describe the time range.
    var title: String {
        switch self {
        case .last5: return "Last 5 Minutes"
        case .lastHour: return "Last Hour"
        case .lastDay: return "Last Day"
        case .total: return "Total"
        }
    }

    /// Provides the string value to be displayed for a particular activity row.
    ///
    /// - Parameters:
    ///   - users: A model containing activity counts for various time periods.
    ///   - total: The total number of users, used only for `.total`.
    /// - Returns: A formatted string representing the user count, or `"N/A"` if unavailable.
    func rowData(
        users: ActiveUsers,
        total: Int)
    -> String {
        switch self {
        case .last5:
            return stringValue(users.last5Minutes)
        case .lastHour:
            return stringValue(users.last1Hour)
        case .lastDay:
            return stringValue(users.last24Hours)
        case .total:
            return String(total)
        }
    }

    // MARK: - Helper Methods

    /// Converts an optional integer to a string, or returns `"N/A"` if nil.
    ///
    /// - Parameter number: The optional integer to convert.
    /// - Returns: A string version of the integer or `"N/A"` if `nil`.
    private func stringValue(_ number: Int?) -> String {
        guard let number = number else { return "N/A" }
        return String(number)
    }
}

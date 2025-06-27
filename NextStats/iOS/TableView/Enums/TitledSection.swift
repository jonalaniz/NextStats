//
//  TitledSection.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/26/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import Foundation

/// A protocol that represents a section composed of multiple titled rows.
///
/// Types conforming to `TitledSection` must be `CaseIterable` enums where each case
/// represents a row with an associated title. This protocol is typically used to provide
/// metadata for building UI sections such as those displayed in a `UITableView`.
protocol TitledSection: CaseIterable {
    /// A human-readable title for the row or section.
    var title: String { get }
}

//
//  StorageRow.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/26/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import Foundation

enum StorageRow: Int, TitledSection {
    case space, files

    var title: String {
        switch self {
        case .space: return "Free Space"
        case .files: return "Number of Files"
        }
    }

    func rowData(system: System, storage: Storage) -> String {
        switch self {
        case .space:
            return freeSpaceString(system.freespace)
        case .files:
            return filesString(storage.numFiles)
        }
    }

    private func filesString(_ value: Int?) -> String {
        guard let number = value else { return "N/A" }
        return String(number)
    }

    private func freeSpaceString(_ value: Int?) -> String {
        guard
            let int = value,
            let bytes = Double(exactly: int),
            bytes.isFinite
        else { return "N/A" }
        return Units(bytes: bytes).getReadableUnit()
    }
}

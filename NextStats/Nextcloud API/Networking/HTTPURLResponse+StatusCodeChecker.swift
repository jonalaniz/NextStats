//
//  HTTPURLResponse+StatusCodeChecker.swift
//  Scouter
//
//  Created by Jon Alaniz on 9/1/24.
//

import Foundation

extension HTTPURLResponse {
    func statusCodeChecker() throws {
        switch self.statusCode {
        case 200...299: return
        default:
            try checkForMaintenance()
            throw APIManagerError.invalidResponse(response: self)
        }
    }

    func checkForMaintenance() throws {
        guard let value = self.value(forHTTPHeaderField: Header.maintenance.key())
        else { return }

        if value == Header.maintenance.value() {
            throw APIManagerError.maintenance
        }
    }
}

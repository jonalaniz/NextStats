//
//  URL+AppendingPathComponentSafely.swift
//  NextStats
//
//  Created by Jon Alaniz on 12/15/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import Foundation

extension URL {
    func appendingPathComponentSafely(_ component: String) -> URL {
        var finalPath = self.path
        if finalPath.hasSuffix("/") {
            finalPath.removeLast()
        }

        return self.appendingPathComponent(component)
    }

    func removingPathComponentSafely() -> URL? {
        guard let range = self.path.range(of: "index.php") else { return nil }

        let truncatedPath = self.path[..<range.lowerBound]
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        components?.path = String(truncatedPath)

        return components?.url
    }
}

//
//  Units.swift
//  NextStats
//
//  Created by fethica:
//  https://gist.github.com/fethica/52ef6d842604e416ccd57780c6dd28e6
//
//  Modified by Jon Alaniz on 1/8/21.
//

public struct Units {

    public let bytes: Double

    public var kilobytes: Double {
        return bytes / 1_024
    }

    public var megabytes: Double {
        return kilobytes / 1_024
    }

    public var gigabytes: Double {
        return megabytes / 1_024
    }

    public init(bytes: Double) {
        self.bytes = bytes
    }

    public init(kilobytes: Double) {
        self.bytes = kilobytes * 1024
    }

    public func getReadableUnit() -> String {
        switch bytes {
        case 0..<1_024:
            return "\(bytes)Bytes"
        case 1_024..<(1_024 * 1_024):
            return "\(String(format: "%.1f", kilobytes))KB"
        case 1_024..<(1_024 * 1_024 * 1_024):
            return "\(String(format: "%.1f", megabytes))MB"
        case (1_024 * 1_024 * 1_024)...Double.greatestFiniteMagnitude:
            return "\(String(format: "%.1f", gigabytes))GB"
        default:
            return "\(bytes)Bytes"
        }
    }
}

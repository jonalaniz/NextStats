//
//  Units.swift
//  NextStats
//
//  Created by fethica:
//  https://gist.github.com/fethica/52ef6d842604e416ccd57780c6dd28e6
//
//  Modified by Jon Alaniz on 1/8/21.
//

struct Units {
    private let bytes: Double
    private let kilobyte = 1024.0
    private let megabyte = 1024.0 * 1024.0
    private let gigabyte = 1024.0 * 1024.0 * 1024.0
    private let terabyte = 1024.0 * 1024.0 * 1024.0 * 1024.0

    private var kilobytes: Double { return bytes / kilobyte }
    private var megabytes: Double { return bytes / megabyte }
    private var gigabytes: Double { return bytes / gigabyte }
    private var terabytes: Double { return bytes / terabyte }

    var readableUnit: String {
        switch bytes {
        case 0 ..< kilobyte: return "\(bytes)Bytes"
        case kilobyte ..< megabyte: return "\(format(kilobytes))KB"
        case megabyte ..< gigabyte: return "\(format(megabytes))MB"
        case gigabyte ..< terabyte: return "\(format(gigabytes))GB"
        default: return "\(format(terabytes))TB"
        }
    }

    init(bytes: Double) {
        self.bytes = bytes
    }

    init(bytes: Int) {
        self.bytes = Double(bytes)
    }

    init(kilobytes: Int) {
        self.bytes = Double(kilobytes) * kilobyte
    }

    init(kilobytes: Double) {
        self.bytes = kilobytes * kilobyte
    }

    private func format(_ value: Double) -> String {
        return value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.1f", value)
    }
}

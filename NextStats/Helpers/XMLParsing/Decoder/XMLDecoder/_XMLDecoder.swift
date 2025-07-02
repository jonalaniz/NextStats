//
//  _XMLDecoder.swift
//  NextStats
//
//  Created by Jon Alaniz on 7/2/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import Foundation

// swiftlint:disable:next type_name
internal class _XMLDecoder: Decoder {
    // MARK: Properties

    /// The decoder's storage.
    internal var storage: _XMLDecodingStorage

    /// Options set on the top-level decoder.
    internal let options: XMLDecoder._Options

    /// The path to the current point in encoding.
    internal(set) public var codingPath: [CodingKey]

    /// Contextual user-provided information for use during encoding.
    public var userInfo: [CodingUserInfoKey: Any] {
        return self.options.userInfo
    }

    // MARK: - Initialization

    /// Initializes `self` with the given top-level container and options.
    internal init(referencing container: Any, at codingPath: [CodingKey] = [], options: XMLDecoder._Options) {
        self.storage = _XMLDecodingStorage()
        self.storage.push(container: container)
        self.codingPath = codingPath
        self.options = options
    }

    // MARK: - Decoder Methods

    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        guard !(self.storage.topContainer is NSNull)
        else {
            throw DecodingError.valueNotFound(
                KeyedDecodingContainer<Key>.self,
                DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Cannot get keyed decoding container -- found null value instead."
                )
            )
        }

        guard let topContainer = self.storage.topContainer as? [String: Any]
        else {
            throw DecodingError._typeMismatch(
                at: self.codingPath,
                expectation: [String: Any].self,
                reality: self.storage.topContainer
            )
        }

        let container = _XMLKeyedDecodingContainer<Key>(
            referencing: self, wrapping: topContainer
        )
        return KeyedDecodingContainer(container)
    }

    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard !(self.storage.topContainer is NSNull)
        else {
            throw DecodingError.valueNotFound(
                UnkeyedDecodingContainer.self,
                DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Cannot get unkeyed decoding container -- found null value instead."
                )
            )
        }

        let topContainer: [Any]

        if let container = self.storage.topContainer as? [Any] {
            topContainer = container
        } else if let container = self.storage.topContainer as? [AnyHashable: Any] {
            topContainer = [container]
        } else {
            throw DecodingError._typeMismatch(
                at: self.codingPath,
                expectation: [Any].self,
                reality: self.storage.topContainer
            )
        }

        return _XMLUnkeyedDecodingContainer(
            referencing: self, wrapping: topContainer
        )
    }

    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        return self
    }
}

// MARK: - Concrete Value Representations

extension _XMLDecoder {
    /// Returns the given value unboxed from a container.
    internal func unbox(_ value: Any, as type: Bool.Type) throws -> Bool? {
        guard !(value is NSNull) else { return nil }

        guard let value = value as? String else { return nil }

        if value == "true" || value == "1" {
            return true
        } else if value == "false" || value == "0" {
            return false
        }

        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }

    internal func unbox(_ value: Any, as type: Int.Type) throws -> Int? {
        guard !(value is NSNull) else { return nil }

        guard let string = value as? String else { return nil }

        guard let value = Float(string) else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
        }

        let number = NSNumber(value: value)

        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }

        let int = number.intValue
        guard NSNumber(value: int) == number else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Parsed XML number <\(number)> does not fit in \(type)."
                )
            )
        }

        return int
    }

    internal func unbox(_ value: Any, as type: Int8.Type) throws -> Int8? {
        guard !(value is NSNull) else { return nil }

        guard let string = value as? String else { return nil }

        guard let value = Float(string) else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
        }

        let number = NSNumber(value: value)

        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }

        let int8 = number.int8Value
        guard NSNumber(value: int8) == number else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Parsed XML number <\(number)> does not fit in \(type)."
                )
            )
        }

        return int8
    }

    internal func unbox(_ value: Any, as type: Int16.Type) throws -> Int16? {
        guard !(value is NSNull) else { return nil }

        guard let string = value as? String else { return nil }

        guard let value = Float(string) else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
        }

        let number = NSNumber(value: value)

        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }

        let int16 = number.int16Value
        guard NSNumber(value: int16) == number else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Parsed XML number <\(number)> does not fit in \(type)."
                )
            )
        }

        return int16
    }

    internal func unbox(
        _ value: Any, as type: Int32.Type
    ) throws -> Int32? {
        guard !(value is NSNull) else { return nil }

        guard let string = value as? String else { return nil }

        guard let value = Float(string) else {
            throw DecodingError._typeMismatch(
                at: self.codingPath,
                expectation: type, reality: string
            )
        }

        let number = NSNumber(value: value)

        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(
                at: self.codingPath,
                expectation: type, reality: value
            )
        }

        let int32 = number.int32Value
        guard NSNumber(value: int32) == number
        else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Parsed XML number <\(number)> does not fit in \(type)."
                )
            )
        }

        return int32
    }

    internal func unbox(
        _ value: Any, as type: Int64.Type
    ) throws -> Int64? {
        guard !(value is NSNull) else { return nil }

        guard let string = value as? String else { return nil }

        guard let value = Float(string) else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
        }

        let number = NSNumber(value: value)

        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }

        let int64 = number.int64Value
        guard NSNumber(value: int64) == number else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Parsed XML number <\(number)> does not fit in \(type)."
                )
            )
        }

        return int64
    }

    internal func unbox(
        _ value: Any, as type: UInt.Type
    ) throws -> UInt? {
        guard !(value is NSNull) else { return nil }

        guard let string = value as? String else { return nil }

        guard let value = Float(string) else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
        }

        let number = NSNumber(value: value)

        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }

        let uint = number.uintValue
        guard NSNumber(value: uint) == number else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Parsed XML number <\(number)> does not fit in \(type)."
                )
            )
        }

        return uint
    }

    internal func unbox(
        _ value: Any, as type: UInt8.Type
    ) throws -> UInt8? {
        guard !(value is NSNull) else { return nil }

        guard let string = value as? String else { return nil }

        guard let value = Float(string) else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
        }

        let number = NSNumber(value: value)

        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }

        let uint8 = number.uint8Value
        guard NSNumber(value: uint8) == number else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Parsed XML number <\(number)> does not fit in \(type)."
                )
            )
        }

        return uint8
    }

    internal func unbox(_ value: Any, as type: UInt16.Type) throws -> UInt16? {
        guard !(value is NSNull) else { return nil }

        guard let string = value as? String else { return nil }

        guard let value = Float(string) else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
        }

        let number = NSNumber(value: value)

        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }

        let uint16 = number.uint16Value
        guard NSNumber(value: uint16) == number else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Parsed XML number <\(number)> does not fit in \(type)."
                )
            )
        }

        return uint16
    }

    internal func unbox(_ value: Any, as type: UInt32.Type) throws -> UInt32? {
        guard !(value is NSNull) else { return nil }

        guard let string = value as? String else { return nil }

        guard let value = Float(string) else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
        }

        let number = NSNumber(value: value)

        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }

        let uint32 = number.uint32Value
        guard NSNumber(value: uint32) == number else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Parsed XML number <\(number)> does not fit in \(type)."
                )
            )
        }

        return uint32
    }

    internal func unbox(_ value: Any, as type: UInt64.Type) throws -> UInt64? {
        guard !(value is NSNull) else { return nil }

        guard let string = value as? String else { return nil }

        guard let value = Float(string) else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
        }

        let number = NSNumber(value: value)

        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }

        let uint64 = number.uint64Value
        guard NSNumber(value: uint64) == number else {
            throw DecodingError.dataCorrupted(

                DecodingError.Context(

                    codingPath: self.codingPath,

                    debugDescription: "Parsed XML number <\(number)> does not fit in \(type)."

                )

            )
        }

        return uint64
    }

    internal func unbox(_ value: Any, as type: Float.Type) throws -> Float? {
        guard !(value is NSNull) else { return nil }

        guard let string = value as? String else { return nil }

        if let value = Double(string) {
            let number = NSNumber(value: value)

            guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
                throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
            }

            let double = number.doubleValue
            guard abs(double) <= Double(Float.greatestFiniteMagnitude)
            else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: self.codingPath,
                        debugDescription: "Parsed XML number \(number) does not fit in \(type)."
                    )
                )
            }

            return Float(double)
        } else if case let .convertFromString(
            posInfString,
            negInfString,
            nanString
        ) = self.options.nonConformingFloatDecodingStrategy {
            if string == posInfString {
                return Float.infinity
            } else if string == negInfString {
                return -Float.infinity
            } else if string == nanString {
                return Float.nan
            }
        }

        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }

    internal func unbox(_ value: Any, as type: Double.Type) throws -> Double? {
        guard !(value is NSNull) else { return nil }

        guard let string = value as? String else { return nil }

        if let number = Decimal(string: string) as NSDecimalNumber? {

            guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
                throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
            }

            return number.doubleValue
        } else if case let .convertFromString(
            posInfString,
            negInfString,
            nanString
        ) = self.options.nonConformingFloatDecodingStrategy {
            if string == posInfString {
                return Double.infinity
            } else if string == negInfString {
                return -Double.infinity
            } else if string == nanString {
                return Double.nan
            }
        }

        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }

    internal func unbox(_ value: Any, as type: String.Type) throws -> String? {
        guard !(value is NSNull) else { return nil }

        guard let string = value as? String else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }

        return string
    }

    internal func unbox(_ value: Any, as type: Date.Type) throws -> Date? {
        guard !(value is NSNull) else { return nil }

        switch self.options.dateDecodingStrategy {
        case .deferredToDate:
            self.storage.push(container: value)
            defer { self.storage.popContainer() }
            return try Date(from: self)

        case .secondsSince1970:
            let double = try self.unbox(value, as: Double.self)!
            return Date(timeIntervalSince1970: double)

        case .millisecondsSince1970:
            let double = try self.unbox(value, as: Double.self)!
            return Date(timeIntervalSince1970: double / 1000.0)

        case .iso8601:
            if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                let string = try self.unbox(value, as: String.self)!
                guard let date = _iso8601Formatter.date(from: string)
                else {
                    throw DecodingError.dataCorrupted(
                        DecodingError.Context(
                            codingPath: self.codingPath,
                            debugDescription: "Expected date string to be ISO8601-formatted."
                        )
                    )
                }

                return date
            } else {
                fatalError("ISO8601DateFormatter is unavailable on this platform.")
            }

        case .formatted(let formatter):
            let string = try self.unbox(value, as: String.self)!
            guard let date = formatter.date(from: string) else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: self.codingPath,
                        debugDescription: "Date string does not match format expected by formatter."
                    )
                )
            }

            return date

        case .custom(let closure):
            self.storage.push(container: value)
            defer { self.storage.popContainer() }
            return try closure(self)
        }
    }

    internal func unbox(_ value: Any, as type: Data.Type) throws -> Data? {
        guard !(value is NSNull) else { return nil }

        switch self.options.dataDecodingStrategy {
        case .deferredToData:
            self.storage.push(container: value)
            defer { self.storage.popContainer() }
            return try Data(from: self)

        case .base64:
            guard let string = value as? String else {
                throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
            }

            guard let data = Data(base64Encoded: string) else {
                throw DecodingError.dataCorrupted(

                    DecodingError.Context(

                        codingPath: self.codingPath,

                        debugDescription: "Encountered Data is not valid Base64."

                    )

                )
            }

            return data

        case .custom(let closure):
            self.storage.push(container: value)
            defer { self.storage.popContainer() }
            return try closure(self)
        }
    }

    internal func unbox(
        _ value: Any, as type: Decimal.Type
    ) throws -> Decimal? {
        guard !(value is NSNull) else { return nil }

        // Attempt to bridge from NSDecimalNumber.
        let doubleValue = try self.unbox(value, as: Double.self)!
        return Decimal(doubleValue)
    }

    internal func unbox<T: Decodable>(
        _ value: Any, as type: T.Type
    ) throws -> T? {
        let decoded: T
        if type == Date.self || type == NSDate.self {
            guard let date = try self.unbox(value, as: Date.self)
            else { return nil }
            // swiftlint:disable:next force_cast
            decoded = date as! T
        } else if type == Data.self || type == NSData.self {
            guard let data = try self.unbox(value, as: Data.self)
            else { return nil }
            // swiftlint:disable:next force_cast
            decoded = data as! T
        } else if type == URL.self || type == NSURL.self {
            guard let urlString = try self.unbox(value, as: String.self)
            else { return nil }

            guard let url = URL(string: urlString) else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: self.codingPath,
                        debugDescription: "Invalid URL string."
                    )
                )
            }

            // swiftlint:disable:next force_cast
            decoded = (url as! T)
        } else if type == Decimal.self || type == NSDecimalNumber.self {
            guard let decimal = try self.unbox(value, as: Decimal.self)
            else { return nil }

            // swiftlint:disable:next force_cast
            decoded = decimal as! T
        } else {
            self.storage.push(container: value)
            defer { self.storage.popContainer() }
            return try type.init(from: self)
        }

        return decoded
    }
}
// swiftlint:disable:this file_length

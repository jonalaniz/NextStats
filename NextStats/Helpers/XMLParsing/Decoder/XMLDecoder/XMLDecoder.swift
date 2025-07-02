//
//  XMLDecoder.swift
//  XMLParsing
//
//  Created by Shawn Moore on 11/20/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

/// `XMLDecoder` facilitates the decoding of XML into semantic
/// `Decodable` types.
open class XMLDecoder {
    // MARK: Options
    /// The strategy to use for decoding `Date` values.
    public enum DateDecodingStrategy {
        /// Defer to `Date` for decoding. This is the default strategy.
        case deferredToDate

        /// Decode the `Date` as a UNIX timestamp from a XML number. This is the default strategy.
        case secondsSince1970

        /// Decode the `Date` as UNIX millisecond timestamp from a XML number.
        case millisecondsSince1970

        /// Decode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
        @available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
        case iso8601

        /// Decode the `Date` as a string parsed by the given formatter.
        case formatted(DateFormatter)

        /// Decode the `Date` as a custom value decoded by the given closure.
        case custom((_ decoder: Decoder) throws -> Date)

        /// Decode the `Date` as a string parsed by the given formatter for the give key.
        static func keyFormatted(
            _ formatterForKey: @escaping (CodingKey) throws -> DateFormatter?
        ) -> XMLDecoder.DateDecodingStrategy {
            return .custom({ (decoder) -> Date in
                guard let codingKey = decoder.codingPath.last
                else {
                    throw DecodingError.dataCorrupted(
                        DecodingError.Context(
                            codingPath: decoder.codingPath,
                            debugDescription: "No Coding Path Found"
                        )
                    )
                }

                guard let container = try? decoder.singleValueContainer(),
                    let text = try? container.decode(String.self)
                else {
                    throw DecodingError.dataCorrupted(
                        DecodingError.Context(
                            codingPath: decoder.codingPath,
                            debugDescription: "Could not decode date text"
                        )
                    )
                }

                guard let dateFormatter = try formatterForKey(codingKey)
                else {
                    throw DecodingError.dataCorruptedError(
                        in: container,
                        debugDescription: "No date formatter for date text"
                    )
                }

                if let date = dateFormatter.date(from: text) {
                    return date
                } else {
                    throw DecodingError.dataCorruptedError(
                        in: container,
                        debugDescription: "Cannot decode date string \(text)"
                    )
                }
            })
        }
    }

    /// The strategy to use for decoding `Data` values.
    public enum DataDecodingStrategy {
        /// Defer to `Data` for decoding.
        case deferredToData

        /// Decode the `Data` from a Base64-encoded string. This is the default strategy.
        case base64

        /// Decode the `Data` as a custom value decoded by the given closure.
        case custom((_ decoder: Decoder) throws -> Data)

        /// Decode the `Data` as a custom value by the given closure for the give key.
        static func keyFormatted(
            _ formatterForKey: @escaping (CodingKey) throws -> Data?
        ) -> XMLDecoder.DataDecodingStrategy {
            return .custom({ (decoder) -> Data in
                guard let codingKey = decoder.codingPath.last
                else {
                    throw DecodingError.dataCorrupted(
                        DecodingError.Context(
                            codingPath: decoder.codingPath,
                            debugDescription: "No Coding Path Found"
                        )
                    )
                }

                guard let container = try? decoder.singleValueContainer(),
                    let text = try? container.decode(String.self)
                else {
                    throw DecodingError.dataCorrupted(
                        DecodingError.Context(
                            codingPath: decoder.codingPath,
                            debugDescription: "Could not decode date text"
                        )
                    )
                }

                guard let data = try formatterForKey(codingKey)
                else {
                    throw DecodingError.dataCorruptedError(
                        in: container,
                        debugDescription: "Cannot decode data string \(text)"
                    )
                }

                return data
            })
        }
    }

    /// The strategy to use for non-XML-conforming floating-point values (IEEE 754 infinity and NaN).
    public enum NonConformingFloatDecodingStrategy {
        /// Throw upon encountering non-conforming values. This is the default strategy.
        case `throw`

        /// Decode the values from the given representation strings.
        case convertFromString(positiveInfinity: String, negativeInfinity: String, nan: String)
    }

    /// The strategy to use for automatically changing the value of keys before decoding.
    public enum KeyDecodingStrategy {
        /// Use the keys specified by each type. This is the default strategy.
        case useDefaultKeys

        /// Convert from "snake_case_keys" to "camelCaseKeys" before attempting to
        /// match a key with the one specified by each type.
        ///
        /// The conversion to upper case uses `Locale.system`, also known as the ICU
        /// "root" locale. This means the result is consistent regardless of the current user's
        /// locale and language preferences.
        ///
        /// Converting from snake case to camel case:
        /// 1. Capitalizes the word starting after each `_`
        /// 2. Removes all `_`
        /// 3. Preserves starting and ending `_` (as these are often used to indicate private
        /// variables or other metadata).
        /// For example, `one_two_three` becomes `oneTwoThree`.
        /// `_one_two_three_` becomes `_oneTwoThree_`.
        ///
        /// - Note: Using a key decoding strategy has a nominal performance cost, as each
        /// string key has to be inspected for the `_` character.
        case convertFromSnakeCase

        /// Provide a custom conversion from the key in the encoded JSON to the keys
        /// specified by the decoded types.
        /// The full path to the current decoding position is provided for context (in
        /// case you need to locate this key within the payload). The returned key is used in
        /// place of the last component in the coding path before decoding.
        /// If the result of the conversion is a duplicate key, then only one value will be
        /// present in the container for the type to decode from.
        case custom((_ codingPath: [CodingKey]) -> CodingKey)

        // swiftlint:disable:next identifier_name
        internal static func _convertFromSnakeCase(
            _ stringKey: String
        ) -> String {
            guard !stringKey.isEmpty else { return stringKey }

            // Find the first non-underscore character
            guard let firstNonUnderscore = stringKey.firstIndex(where: { $0 != "_" }) else {
                // Reached the end without finding an _
                return stringKey
            }

            // Find the last non-underscore character
            var lastNonUnderscore = stringKey.index(before: stringKey.endIndex)
            while lastNonUnderscore > firstNonUnderscore && stringKey[lastNonUnderscore] == "_" {
                stringKey.formIndex(before: &lastNonUnderscore)
            }

            let keyRange = firstNonUnderscore...lastNonUnderscore
            let leadingUnderscoreRange = stringKey.startIndex..<firstNonUnderscore
            let trailingUnderscoreRange = stringKey.index(after: lastNonUnderscore)..<stringKey.endIndex

            let components = stringKey[keyRange].split(separator: "_")
            let joinedString: String
            if components.count == 1 {
                // No underscores in key, leave the word as is - maybe already camel cased
                joinedString = String(stringKey[keyRange])
            } else {
                joinedString = ([components[0].lowercased()] + components[1...].map { $0.capitalized }).joined()
            }

            // Do a cheap isEmpty check before creating and appending potentially empty strings
            let result: String
            if leadingUnderscoreRange.isEmpty && trailingUnderscoreRange.isEmpty {
                result = joinedString
            } else if !leadingUnderscoreRange.isEmpty && !trailingUnderscoreRange.isEmpty {
                // Both leading and trailing underscores
                result = String(
                    stringKey[leadingUnderscoreRange]
                ) + joinedString + String(
                    stringKey[trailingUnderscoreRange]
                )
            } else if !leadingUnderscoreRange.isEmpty {
                // Just leading
                result = String(stringKey[leadingUnderscoreRange]) + joinedString
            } else {
                // Just trailing
                result = joinedString + String(stringKey[trailingUnderscoreRange])
            }
            return result
        }
    }

    /// The strategy to use in decoding dates. Defaults to `.secondsSince1970`.
    open var dateDecodingStrategy: DateDecodingStrategy = .secondsSince1970

    /// The strategy to use in decoding binary data. Defaults to `.base64`.
    open var dataDecodingStrategy: DataDecodingStrategy = .base64

    /// The strategy to use in decoding non-conforming numbers. Defaults to `.throw`.
    open var nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy = .throw

    /// The strategy to use for decoding keys. Defaults to `.useDefaultKeys`.
    open var keyDecodingStrategy: KeyDecodingStrategy = .useDefaultKeys

    /// Contextual user-provided information for use during decoding.
    open var userInfo: [CodingUserInfoKey: Any] = [:]

    /// Options set on the top-level encoder to pass down the decoding hierarchy.
    internal struct _Options {
        // swiftlint:disable:previous type_name
        let dateDecodingStrategy: DateDecodingStrategy
        let dataDecodingStrategy: DataDecodingStrategy
        let nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy
        let keyDecodingStrategy: KeyDecodingStrategy
        let userInfo: [CodingUserInfoKey: Any]
    }

    /// The options set on the top-level decoder.
    internal var options: _Options {
        return _Options(
            dateDecodingStrategy: dateDecodingStrategy,
            dataDecodingStrategy: dataDecodingStrategy,
            nonConformingFloatDecodingStrategy: nonConformingFloatDecodingStrategy,
            keyDecodingStrategy: keyDecodingStrategy,
            userInfo: userInfo
        )
    }

    // MARK: - Constructing a XML Decoder
    /// Initializes `self` with default strategies.
    public init() {}

    // MARK: - Decoding Values
    /// Decodes a top-level value of the given type from the given XML representation.
    ///
    /// - parameter type: The type of the value to decode.
    /// - parameter data: The data to decode from.
    /// - returns: A value of the requested type.
    /// - throws: `DecodingError.dataCorrupted` if values requested from
    /// the payload are corrupted, or if the given data is not valid XML.
    /// - throws: An error if any value throws an error during decoding.
    open func decode<T: Decodable>(
        _ type: T.Type, from data: Data
    ) throws -> T {
        let topLevel: [String: Any]
        do {
            topLevel = try _XMLStackParser.parse(with: data)
        } catch {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "The given data was not valid XML.",
                    underlyingError: error
                )
            )
        }

        let decoder = _XMLDecoder(referencing: topLevel, options: self.options)

        guard let value = try decoder.unbox(topLevel, as: type)
        else {
            throw DecodingError.valueNotFound(
                type,
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "The given data did not contain a top-level value."
                )
            )
        }

        return value
    }
}

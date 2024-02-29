//
//  SourceCode.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import Foundation

struct SourceCode {
    /// The source code represented in string form
    let string: String
}

extension SourceCode: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        string = value
    }
}

extension SourceCode: CustomStringConvertible {
    var description: String { string }
}

extension SourceCode: SwiftRepresentable {
    var swiftCode: SourceCode { self }
}

extension SourceCode: ExpressibleByStringInterpolation {
    /// Provides string interpolation capabilities useful when building source code
    /// In particular, multi-line interpolated strings are indented as you would expect.
    ///
    /// Example usage:
    /// ```
    /// let functionBody = "let text = "Hello world"\nprint(text)"
    /// let sourceCode: SourceCode = """
    /// func hi() {
    ///   \(functionBody)
    /// }
    /// """
    /// print(sourceCode)
    /// ```
    /// This outputs:
    /// ```
    /// func hi() {
    ///   let text = "Hello world"
    ///   print(text)
    /// }
    /// ```
    struct StringInterpolation: StringInterpolationProtocol {
        var output = ""

        init(literalCapacity: Int, interpolationCount: Int) {}

        mutating func appendLiteral(_ literal: String) {
            output.append(literal)
        }

        mutating func appendInterpolation(_ string: String) {
            output.append(string)
        }

        mutating func appendInterpolation(_ swiftRepresentable: SwiftRepresentable) {
            let indentation = String(output.suffix(while: { character in
                character.isWhitespace && !character.isNewline
            }))
            let string = swiftRepresentable.swiftCode.string

            output.append(string.indented(with: indentation, excludingFirstLine: true))
        }
    }

    init(stringInterpolation: StringInterpolation) {
        string = stringInterpolation.output
    }
}

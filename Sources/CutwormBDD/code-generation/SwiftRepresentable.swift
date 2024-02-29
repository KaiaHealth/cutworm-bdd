//
//  SwiftRepresentable.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import Foundation

protocol SwiftRepresentable {
    var swiftCode: SourceCode { get }
}

extension Array {
    func joined(separator: String) -> SwiftRepresentable where Element: SwiftRepresentable {
        SourceCode(stringLiteral: map(\.swiftCode.string).joined(separator: separator))
    }
}

//
//  StringProtocol+Casing.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import Foundation

extension StringProtocol {
    private var upperCasingFirst: String { prefix(1).uppercased() + dropFirst() }

    var upperCamelCased: String {
        guard !isEmpty else { return "" }
        let parts = components(separatedBy: .alphanumerics.inverted)
        return parts.map { $0.upperCasingFirst }.joined()
    }
}

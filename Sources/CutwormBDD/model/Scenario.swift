//
//  Scenario.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import Foundation

struct Scenario: Equatable {
    /// Has to be unique per feature, used as identifier
    let name: String
    let steps: [Step]
}

extension Scenario: SwiftRepresentable {
    var swiftCode: SourceCode {
        """
        func test\(name.upperCamelCased)() {
            Scenario("\(name)")
            \(steps.joined(separator: "\n\n"))

        }
        """
    }
}

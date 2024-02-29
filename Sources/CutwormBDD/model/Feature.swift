//
//  Feature.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import Foundation

struct Feature: Equatable {
    let name: String
    let scenarios: [Scenario]
}

extension Feature: SwiftRepresentable {
    var swiftCode: SourceCode {
        """
        import XCTest
        import CutwormBDD

        final class \(name.upperCamelCased)Tests: XCTestCase, BDDTestCase {

            override func setUp() {
                super.setUp()

                Feature("\(name)")
            }

            \(scenarios.joined(separator: "\n\n"))
        }
        """
    }
}

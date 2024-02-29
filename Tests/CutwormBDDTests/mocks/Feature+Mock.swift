//
//  BDDFeature+Mock.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

@testable import CutwormBDD

extension Feature {
    static func mock() -> Self {
        Self(
            name: "Authentication",
            scenarios: [Scenario.mock()]
        )
    }
}

//
//  Scenario+Mock.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

@testable import CutwormBDD

extension Scenario {
    static func mock() -> Self {
        Scenario(
            name: "Log in",
            steps: [
                Step(type: .given, name: "the user has an account"),
                Step(type: .when, name: "the user enters their password"),
                Step(type: .then, name: "the user is logged in")
            ]
        )
    }
}

//
//  ScenarioResult+Mock.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import Foundation
@testable import CutwormBDD

extension ScenarioResult {
    static func mock() -> Self {
        ScenarioResult(
            feature: .mock(),
            scenario: .mock(),
            stepResults: [
                StepResult(
                    step: Step(type: .given, name: "the user has an account"),
                    startDate: Date(timeIntervalSince1970: 0),
                    endDate: Date(timeIntervalSince1970: 1),
                    status: .success
                ),
                StepResult(
                    step: Step(type: .when, name: "the user enters their password"),
                    startDate: Date(timeIntervalSince1970: 1),
                    endDate: Date(timeIntervalSince1970: 3),
                    status: .failure
                ),
                StepResult(
                    step: Step(type: .then, name: "the user is logged in"),
                    startDate: Date(timeIntervalSince1970: 3),
                    endDate: Date(timeIntervalSince1970: 3),
                    status: .skipped
                )
            ]
        )
    }
}

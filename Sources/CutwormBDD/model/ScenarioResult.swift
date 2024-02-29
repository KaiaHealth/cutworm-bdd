//
//  ScenarioResult.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import Foundation

struct ScenarioResult {
    let feature: Feature
    let scenario: Scenario

    var stepResults: [StepResult] = []
}

extension ScenarioResult: CustomStringConvertible {
    var description: String {
        let steps = stepResults
            .map { String(describing: $0) }
            .joined(separator: "\n")

        return """
        Feature: \(feature.name)
        Scenario: \(scenario.name)
        Steps:
        \(steps)
        """
    }
}

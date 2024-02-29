//
//  ResultJSONBuilder.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import Foundation

enum ResultJSONBuilder {
    /// Returns file name in the following format: `bdd-test-results-{host}.json`
    static func fileName(from execution: TestExecutionInfo) -> String {
        "bdd-test-results-\(execution.hostName).json"
    }

    static func build(from results: [ScenarioResult]) throws -> Data {
        // Create dictionary of features with empty step results
        var featuresDictionary = results
            .map { $0.feature }
            .reduce(into: [String: [String: Any]](), { allFeatures, feature in
                let featureName = feature.name
                if allFeatures[featureName] == nil {
                    allFeatures[featureName] = [
                        "name": featureName,
                        "uri": "",
                        "keyword": "Feature",
                        "description": featureName,
                        "id": featureName,
                        "elements": [[String: Any]]()
                    ]
                }
            })

        // Create JSON for each step result and append to respective features
        for scenarioResult in results {
            let featureName = scenarioResult.feature.name
            guard var featureScenarioResults = featuresDictionary[featureName]?["elements"] as? [[String: Any]] else {
                fatalError("Failed to find a valid entry in the feature dictionary for \(featureName)!")
            }

            let stepResults = scenarioResult.stepResults.map { stepResult in
                let durationInSeconds = stepResult.duration
                // Result JSON schema is using nanoseconds for duration
                let durationInNanoseconds = Float(durationInSeconds) * Float(NSEC_PER_SEC)
                return [
                    "name": stepResult.step.name,
                    "keyword": stepResult.step.type.rawValue.lowercased(),
                    "result": [
                        "status": stepResult.status == .success ? "passed" : "failed",
                        "duration": durationInNanoseconds
                    ] as [String: Any]
                ] as [String: Any]
            }
            featureScenarioResults.append(
                [
                    "id": scenarioResult.scenario.name,
                    "name": scenarioResult.scenario.name,
                    "type": "scenario",
                    "description": scenarioResult.scenario.name,
                    "keyword": "Scenario",
                    "steps": stepResults
                ]
            )
            featuresDictionary[scenarioResult.feature.name]?["elements"] = featureScenarioResults
        }

        let features = featuresDictionary.values.compactMap { $0 }
        return try JSONSerialization.data(withJSONObject: features, options: [.prettyPrinted, .sortedKeys])
    }
}

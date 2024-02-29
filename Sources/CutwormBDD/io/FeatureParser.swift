//
//  FeatureParser.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import Foundation

enum FeatureParser {
    /// Parses the feature and the scenarios from the given text into a `Feature` instance.
    static func parse(text: String) throws -> Feature {
        var lines = [String]()
        // Handles `\r\n` in addition to the typical `\n`
        text.enumerateLines(invoking: { line, stop in
            lines.append(line)
        })
        var currentIndex = 0

        // Skip comments and language declaration
        while lines[currentIndex].starts(with: "#") {
            currentIndex += 1
        }

        // Parse feature name
        let featureName = lines[currentIndex].replacingOccurrences(of: "Feature: ", with: "")
        currentIndex += 1

        // Skip any additional new lines
        while lines[currentIndex].isEmpty {
            currentIndex += 1
        }

        // Parse scenarios
        var scenarios: [Scenario] = []
        var currentScenarioSteps: [Step] = []
        var currentScenarioName = ""

        while currentIndex < lines.count {
            let line = lines[currentIndex].trimmingCharacters(in: .whitespaces)

            // Scenario definitions can start with `Scenario` or `Scenario Outline`
            if line.starts(with: "Scenario") {
                // Append the previous scenario before starting to parse a new one
                if !currentScenarioName.isEmpty && !currentScenarioSteps.isEmpty {
                    scenarios.append(Scenario(name: currentScenarioName, steps: currentScenarioSteps))
                }

                if line.starts(with: "Scenario Outline: ") {
                    currentScenarioName = line.replacingOccurrences(of: "Scenario Outline: ", with: "")
                } else if line.starts(with: "Scenario: ") {
                    currentScenarioName = line.replacingOccurrences(of: "Scenario: ", with: "")
                } else {
                    throw CutwormBDDError.scenarioInvalid(line: line)
                }
                currentScenarioSteps = []
            } else if !line.isEmpty, let stepType = parseStepType(line) {
                let stepDefinition = line.replacingOccurrences(of: "\(stepType.rawValue) ", with: "")
                currentScenarioSteps.append(Step(type: stepType, name: stepDefinition))
            } else {
                // We ignore the line
            }

            currentIndex += 1
        }

        if !currentScenarioName.isEmpty && !currentScenarioSteps.isEmpty {
            scenarios.append(Scenario(name: currentScenarioName, steps: currentScenarioSteps))
        }

        return Feature(name: featureName, scenarios: scenarios)
    }

    private static func parseStepType(_ line: String) -> StepType? {
        guard let rawValue = line.components(separatedBy: " ").first else {
            return nil
        }

        return StepType(rawValue: rawValue)
    }
}

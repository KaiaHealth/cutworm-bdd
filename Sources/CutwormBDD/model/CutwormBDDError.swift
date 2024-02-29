//
//  CutwormBDDError.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import Foundation

enum CutwormBDDError: Error, LocalizedError {
    case duplicatedFeaturesFound(names: [String])
    case featureNotFound(name: String)
    case featureNotActive
    case featuresDirectoryNotFound(bundle: Bundle)
    case scenarioAlreadyActive
    case scenarioIncomplete(Scenario, unimplementedSteps: [Step])
    case scenarioInvalid(line: String)
    case scenarioNotActive(feature: Feature)
    case scenarioNotFound(name: String, feature: Feature)
    case stepInvalid(expected: Step?, actual: Step, scenario: Scenario)

    var errorDescription: String? {
        switch self {
        case .duplicatedFeaturesFound(let names):
            return "Found multiple features with the same name: \(names.map { "\"\($0)\"" }.joined(separator: ", "))"
        case .featureNotFound(let name):
            return "No feature found with name \"\(name)\"."
        case .featureNotActive:
            return "`Feature(_ name: String)` must be called first."
        case .featuresDirectoryNotFound(let bundle):
            return "Could not find `features` directory in the bundle at \(bundle.bundlePath)."
        case .scenarioAlreadyActive:
            return "The current scenario must be completed first."
        case .scenarioIncomplete(_, let unimplementedSteps):
            let formattedSteps = unimplementedSteps.map(\.swiftCode.string).joined(separator: "\n")

            return """
                Some steps were not implemented for the scenario:
                \(formattedSteps)
                """
        case .scenarioInvalid(let line):
            return "Scenario declaration could not be decoded: \"\(line)\""
        case .scenarioNotActive:
            return "`Scenario(_ name: String)` must be called first."
        case .scenarioNotFound(let name, let feature):
            return "No scenario found with name \"\(name)\" for feature \"\(feature.name)\"."
        case .stepInvalid(let expected, let actual, _):
            if let expected {
                return "Expected `\(expected.swiftCode)` instead of `\(actual.swiftCode)`"
            } else {
                return "Expected end of scenario instead of `\(actual.swiftCode)`"
            }
        }
    }

    var suggestedSwiftCode: SourceCode? {
        switch self {
        case .scenarioIncomplete(let scenario, _),
                .stepInvalid(_, _, let scenario):
            return scenario.swiftCode
        case .scenarioNotFound(_, let feature):
            return feature.swiftCode
        case .duplicatedFeaturesFound,
                .featureNotFound,
                .featureNotActive,
                .featuresDirectoryNotFound,
                .scenarioAlreadyActive,
                .scenarioInvalid,
                .scenarioNotActive:
            return nil
        }
    }
}

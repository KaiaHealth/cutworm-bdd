//
//  BDDTestCase+CodeGeneration.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import Foundation

extension BDDTestCase {
    /// Replaces the file where this function was called with tests generated from the Gherkin file.
    /// **Do not call this from a file where you have unsaved changes, as they will be overwritten!**
    ///
    /// - Parameters:
    ///   - name: The name of the feature, as defined in the Gherkin file.
    ///
    /// Simply call this function from a test case, and run tests to generate
    /// code that calls the BDD steps based on the Gherkin file.
    /// ```swift
    /// class AuthenticationTests: XCTestCase, BDDTestCase {
    ///     override func setUp() {
    ///         super.setUp()
    ///
    ///         GenerateFeature_EXPERIMENTAL("Authentication")
    ///     }
    /// }
    /// ```
    public func GenerateFeature_EXPERIMENTAL(
        _ name: String,
        in bundle: Bundle = Bundle(for: Self.self),
        file: StaticString = #file,
        line: UInt = #line
    ) {
        assertNoThrow(file: file, line: line) {
            let featureRepository = try FeatureRepository.repository(for: bundle)
            let feature = try featureRepository.getFeature(name)

            let editor = FeatureFileEditor(feature: feature)
            try editor.performEdits(atPath: String(file))
        }
    }

    /// Replaces the contents of the function where this was called with a generated scenario test.
    /// **Do not call this from a file where you have unsaved changes, they may be overwritten!**
    ///
    /// - Parameters:
    ///   - name: The name of the scenario, as defined in the Gherkin file.
    ///
    /// Simply call this function from a test case, and run your test to generate
    /// code that calls the BDD steps based on the Gherkin file.
    /// ```swift
    /// func testLogin() {
    ///     GenerateScenario_EXPERIMENTAL("Email login with valid credentials")
    /// }
    /// ```
    public func GenerateScenario_EXPERIMENTAL(
        _ name: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        assertNoThrow(file: file, line: line) {
            guard let feature = featureTester.feature else {
                throw CutwormBDDError.featureNotActive
            }

            guard let scenario = feature.scenarios.first(where: { $0.name == name }) else {
                throw CutwormBDDError.scenarioNotFound(name: name, feature: feature)
            }

            let editor = ScenarioFileEditor(scenario: scenario, insertAtLine: Int(line))
            try editor.performEdits(atPath: String(file))
        }
    }
}

private extension String {
    init(_ staticString: StaticString) {
        self = staticString.withUTF8Buffer {
            String(decoding: $0, as: UTF8.self)
        }
    }
}

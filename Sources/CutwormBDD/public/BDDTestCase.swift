//
//  BDDTestCase.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import XCTest

public protocol BDDTestCase: XCTestCase, BDDStepChainable {}

public extension BDDTestCase {
    /// Informs CutwormBDD which feature is under test.
    ///
    /// - Parameters:
    ///   - name: The name of the feature, as defined in the Gherkin file. This is used to find the corresponding feature definition.
    ///   - bundle: The bundle where the feature files are located.
    ///     The feature files must be placed inside a `features` directory within the bundle.
    ///     When using a Swift Package test target, pass `.module`.
    ///
    /// If your test case is designed to test scenarios from a single feature (recommended), you can call this in the `setUp()` method.
    ///
    /// ```swift
    /// class AuthenticationTests: XCTestCase, BDDTestCase {
    ///     override func setUp() {
    ///         super.setUp()
    ///
    ///         // Informs Cutworm which feature is under test
    ///         Feature("Authentication", in: .module)
    ///     }
    ///
    ///     // Your test methods
    /// }
    /// ```
    func Feature(
        _ name: String,
        in bundle: Bundle = Bundle(for: Self.self),
        file: StaticString = #file,
        line: UInt = #line
    ) {
        assertNoThrow(file: file, line: line) {
            let featureRepository = try FeatureRepository.repository(for: bundle)
            try featureTester.evaluateFeature(
                try featureRepository.getFeature(name)
            )
        }
    }

    /// Informs CutwormBDD which scenario is under test.
    ///
    /// - Parameters:
    ///   - name: The name of the scenario, as defined in the Gherkin file. This is used to find the corresponding scenario definition.
    ///
    /// You can call this method at the beginning of your test, assuming you have one-to-one mapping between your tests and scenarios (recommended).
    /// ```swift
    /// func testLogin() throws {
    ///     Scenario("Email login with valid credentials")
    ///
    ///     // Your test implementation
    /// }
    /// ```
    func Scenario(
        _ name: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let testObservationCenter = TestObservationCenter.shared
        let testEventPublisher = testObservationCenter.issuePublisher
            .map { _ in FeatureTester.TestEvent.issueOccurred }
            .eraseToAnyPublisher()

        featureTester.receiveTestEvents(testEventPublisher)

        assertNoThrow(file: file, line: line) {
            try featureTester.beginScenario(name: name)

            addTeardownBlock { [unowned self] in
                assertNoThrow(file: file, line: line) {
                    guard featureTester.isScenarioActive else {
                        // `EndScenario()` was called already.
                        return
                    }
                    try featureTester.endScenario()
                }
            }
        }
    }

    /// Ends the currently running scenario.
    ///
    /// This happens automatically when the test ends and should only be called
    /// manually when testing several scenarios in the same test (not recommended).
    ///
    /// ```swift
    /// func testLogin() throws {
    ///     Scenario("Email login with valid credentials")
    ///     // Your first scenario implementation
    ///     EndScenario()
    ///
    ///     Scenario("Email login with invalid credentials")
    ///     // Your second scenario implementation
    ///     // Calling `EndScenario` is not needed, as it is called implicitly when the test ends.
    /// }
    /// ```
    func EndScenario(
        file: StaticString = #file,
        line: UInt = #line
    ) {
        assertNoThrow(file: file, line: line) {
            try featureTester.endScenario()
        }
    }
}

//
//  FeatureTesterTests.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import XCTest
@testable import CutwormBDD

/// Tests the integration of `FeatureTester` and `ScenarioTester`
final class FeatureTesterTests: XCTestCase {

    // MARK: - Successful tests

    func testPerformSuccessfulScenario() throws {
        let resultRepository = ResultRepository()
        let tester = FeatureTester(resultRepository: resultRepository)

        try tester.evaluateFeature(.mock())

        try tester.beginScenario(name: "Log in")
        try tester.perform(step: Step(type: .given, name: "the user has an account"))
        try tester.perform(step: Step(type: .when, name: "the user enters their password"))
        try tester.perform(step: Step(type: .then, name: "the user is logged in"))
        try tester.endScenario()

        let result = try XCTUnwrap(resultRepository.results.first)

        XCTAssertEqual(result.scenario.name, "Log in")
        XCTAssertEqual(result.stepResults.map(\.status), [.success, .success, .success])
    }

    // MARK: - Failed tests

    func testPerformScenarioWithFailure() throws {
        let resultRepository = ResultRepository()
        let tester = FeatureTester(resultRepository: resultRepository)

        try tester.evaluateFeature(.mock())

        try tester.beginScenario(name: "Log in")
        try tester.perform(step: Step(type: .given, name: "the user has an account"))
        tester.handleEvent(.failureOccurred)
        try tester.perform(step: Step(type: .when, name: "the user enters their password"))
        try tester.perform(step: Step(type: .then, name: "the user is logged in"))
        try tester.endScenario()

        let result = try XCTUnwrap(resultRepository.results.first)
        XCTAssertEqual(result.scenario.name, "Log in")
        guard result.stepResults.count == 3 else {
            XCTFail("Unexpected step results count")
            return
        }

        XCTAssertEqual(result.stepResults.map(\.status), [.failure, .success, .success])
    }

    func testPerformScenarioWithAbortOnFailure() throws {
        let resultRepository = ResultRepository()
        let tester = FeatureTester(resultRepository: resultRepository)

        try tester.evaluateFeature(.mock())

        try tester.beginScenario(name: "Log in")
        try tester.perform(step: Step(type: .given, name: "the user has an account"))
        tester.handleEvent(.failureOccurred)
        // Simulate `continueAfterFailure = false`: after a failure occurs, the following steps won't be executed.
        try tester.endScenario()

        let result = try XCTUnwrap(resultRepository.results.first)
        XCTAssertEqual(result.scenario.name, "Log in")
        XCTAssertEqual(result.stepResults.map(\.status), [.failure, .skipped, .skipped])
    }

    // MARK: - Partially implemented tests

    func testPerformScenarioWithUnimplementedSteps() throws {
        let resultRepository = ResultRepository()
        let tester = FeatureTester(resultRepository: resultRepository)

        try tester.evaluateFeature(.mock())

        try tester.beginScenario(name: "Log in")
        try tester.perform(step: Step(type: .given, name: "the user has an account"))
        XCTAssertThrowsError(try tester.endScenario()) { error in
            guard case CutwormBDDError.scenarioIncomplete(_, let unimplementedSteps) = error else {
                XCTFail("Unexpected error: \(error)")
                return
            }

            XCTAssertEqual(unimplementedSteps.count, 2)
        }

        let result = try XCTUnwrap(resultRepository.results.first)
        XCTAssertEqual(result.scenario.name, "Log in")
        XCTAssertEqual(result.stepResults.map(\.status), [.success, .notImplemented, .notImplemented])
    }

    // MARK: - Incorrect usage

    func testPerformScenarioWithInvalidStep() throws {
        let resultRepository = ResultRepository()
        let tester = FeatureTester(resultRepository: resultRepository)

        try tester.evaluateFeature(.mock())
        try tester.beginScenario(name: "Log in")

        try tester.perform(step: Step(type: .given, name: "the user has an account"))

        XCTAssertThrowsError(
            try tester.perform(step: Step(type: .when, name: "invalid"))
        ) { error in
            guard case CutwormBDDError.stepInvalid = error else {
                XCTFail("Unexpected error: \(error)")
                return
            }
        }

        XCTAssertNoThrow(
            try tester.perform(step: Step(type: .then, name: "another invalid")),
            "Only the first invalid step gets an error, as errors on following steps could be confusing"
        )
        try tester.endScenario()

        let result = try XCTUnwrap(resultRepository.results.first)
        XCTAssertEqual(result.stepResults.map(\.status), [.success, .skipped, .skipped])
    }

    func testPerformScenarioMoreStepsThanDefined() throws {
        let resultRepository = ResultRepository()
        let tester = FeatureTester(resultRepository: resultRepository)

        try tester.evaluateFeature(.mock())
        try tester.beginScenario(name: "Log in")

        try tester.perform(step: Step(type: .given, name: "the user has an account"))
        try tester.perform(step: Step(type: .when, name: "the user enters their password"))
        try tester.perform(step: Step(type: .then, name: "the user is logged in"))
        XCTAssertThrowsError(
            try tester.perform(step: Step(type: .and, name: "the user sees their data"))
        ) { error in
            guard case CutwormBDDError.stepInvalid = error else {
                XCTFail("Unexpected error: \(error)")
                return
            }
        }
        try tester.endScenario()

        let result = try XCTUnwrap(resultRepository.results.first)
        XCTAssertEqual(
            result.stepResults.map(\.status), [.success, .success, .success],
            "Only the steps defined in the scenario are reported."
        )
    }

    func testBeginScenarioWithoutActiveFeature() {
        let tester = FeatureTester(resultRepository: ResultRepository())

        XCTAssertThrowsError(
            try tester.beginScenario(name: "Log in")
        ) { error in
            guard case CutwormBDDError.featureNotActive = error else {
                XCTFail("Unexpected error: \(error)")
                return
            }
        }
    }

    func testEvaluateFeatureWithOngoingScenario() throws {
        let tester = FeatureTester(resultRepository: ResultRepository())

        try tester.evaluateFeature(.mock())

        try tester.beginScenario(name: "Log in")

        XCTAssertThrowsError(
            try tester.evaluateFeature(.mock())
        ) { error in
            guard case CutwormBDDError.scenarioAlreadyActive = error else {
                XCTFail("Unexpected error: \(error)")
                return
            }
        }
    }

    func testBeginScenarioWithOngoingScenario() throws {
        let tester = FeatureTester(resultRepository: ResultRepository())

        try tester.evaluateFeature(.mock())
        try tester.beginScenario(name: "Log in")

        XCTAssertThrowsError(
            try tester.beginScenario(name: "Log in")
        ) { error in
            guard case CutwormBDDError.scenarioAlreadyActive = error else {
                XCTFail("Unexpected error: \(error)")
                return
            }
        }
    }

    func testBeginNonExistentScenario() throws {
        let tester = FeatureTester(resultRepository: ResultRepository())

        try tester.evaluateFeature(.mock())
        XCTAssertThrowsError(
            try tester.beginScenario(name: "Sign in")
        ) { error in
            guard case CutwormBDDError.scenarioNotFound = error else {
                XCTFail("Unexpected error: \(error)")
                return
            }
        }
    }

    func testPerformStepWithoutActiveFeature() throws {
        let tester = FeatureTester(resultRepository: ResultRepository())

        XCTAssertThrowsError(
            try tester.perform(step: Step(type: .given, name: "the user has an account"))
        ) { error in
            guard case CutwormBDDError.featureNotActive = error else {
                XCTFail("Unexpected error: \(error)")
                return
            }
        }
    }

    func testPerformStepWithoutActiveScenario() throws {
        let tester = FeatureTester(resultRepository: ResultRepository())

        try tester.evaluateFeature(.mock())
        XCTAssertThrowsError(
            try tester.perform(step: Step(type: .given, name: "the user has an account"))
        ) { error in
            guard case CutwormBDDError.scenarioNotActive = error else {
                XCTFail("Unexpected error: \(error)")
                return
            }
        }
    }

    func testEndScenarioWithoutActiveFeature() throws {
        let tester = FeatureTester(resultRepository: ResultRepository())

        XCTAssertThrowsError(
            try tester.endScenario()
        ) { error in
            guard case CutwormBDDError.featureNotActive = error else {
                XCTFail("Unexpected error: \(error)")
                return
            }
        }
    }

    func testEndScenarioWithoutActiveScenario() throws {
        let tester = FeatureTester(resultRepository: ResultRepository())

        try tester.evaluateFeature(.mock())

        XCTAssertThrowsError(
            try tester.endScenario()
        ) { error in
            guard case CutwormBDDError.scenarioNotActive = error else {
                XCTFail("Unexpected error: \(error)")
                return
            }
        }
    }
}

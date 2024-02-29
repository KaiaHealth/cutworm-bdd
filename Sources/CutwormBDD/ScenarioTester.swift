//
//  ScenarioTester.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import Foundation

final class ScenarioTester {
    struct StepState {
        let step: Step
        let startDate: Date
        var isFailed = false
    }

    private var scenarioResult: ScenarioResult
    private var currentStepState: StepState?
    private var hasReceivedInvalidStep = false

    init(feature: Feature, scenario: Scenario) {
        scenarioResult = ScenarioResult(feature: feature, scenario: scenario)
    }

    func perform(step: Step) throws {
        // Stop handling steps after receiving an invalid one, because the errors on subsequent steps could be confusing.
        guard !hasReceivedInvalidStep else { return }

        endStepIfNeeded()

        do {
            try validateBeginStep(step)
        } catch {
            hasReceivedInvalidStep = true
            throw error
        }

        currentStepState = StepState(step: step, startDate: Date())
    }

    func finalize() -> ScenarioResult {
        endStepIfNeeded()
        appendMissingStepResults()

        return scenarioResult
    }

    func handle(event: FeatureTester.TestEvent) {
        switch event {
        case .issueOccurred:
            currentStepState?.isFailed = true
        }
    }

    private func validateBeginStep(_ actualStep: Step) throws {
        let stepIndex = scenarioResult.stepResults.count

        let allSteps = scenarioResult.scenario.steps
        guard allSteps.indices.contains(stepIndex) else {
            throw CutwormBDDError.stepInvalid(expected: nil, actual: actualStep, scenario: scenarioResult.scenario)
        }

        let expectedStep = allSteps[stepIndex]
        guard expectedStep == actualStep else {
            throw CutwormBDDError.stepInvalid(expected: expectedStep, actual: actualStep, scenario: scenarioResult.scenario)
        }
    }

    private func endStepIfNeeded() {
        guard let currentStepState = currentStepState else {
            return
        }

        self.currentStepState = nil

        let stepResult = StepResult(
            step: currentStepState.step,
            startDate: currentStepState.startDate,
            endDate: Date(),
            status: currentStepState.isFailed ? .failure : .success
        )
        scenarioResult.stepResults.append(stepResult)
    }

    private func appendMissingStepResults() {
        // Appends results for steps that weren't completed during the test.
        // This happens in two cases:
        // - a test failure occurs while using `continueAfterFailure = false` -> all following steps are skipped
        // - some steps were not implemented
        // In the case of failure, we assume the step was implemented and was just skipped, this should be the common case.
        let status = scenarioResult.stepResults.last?.status == .failure || hasReceivedInvalidStep ? Status.skipped : .notImplemented

        let stepResultsCount = scenarioResult.stepResults.count
        guard stepResultsCount < scenarioResult.scenario.steps.count else { return }

        let steps = scenarioResult.scenario.steps
        let missingSteps = steps[stepResultsCount..<steps.endIndex]
        let currentDate = Date()

        scenarioResult.stepResults += missingSteps.map { step in
            StepResult(step: step, startDate: currentDate, endDate: currentDate, status: status)
        }
    }
}

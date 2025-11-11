//
//  FeatureTester.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import Foundation
import Combine

final class FeatureTester {
    enum TestEvent {
        case failureOccurred
    }

    static let shared = FeatureTester()

    var isScenarioActive: Bool { scenarioTester != nil }

    private(set) var feature: Feature?
    private var testEventCancellable: AnyCancellable?
    private var scenarioTester: ScenarioTester?

    /// Get the active scenario tester, throws an error if there is none.
    private var activeScenarioTester: ScenarioTester {
        get throws {
            guard let feature else { throw CutwormBDDError.featureNotActive }

            guard let scenarioTester else { throw CutwormBDDError.scenarioNotActive(feature: feature) }

            return scenarioTester
        }
    }

    private let resultRepository: ResultRepository

    init(resultRepository: ResultRepository = ResultRepository.shared) {
        self.resultRepository = resultRepository
    }

    func evaluateFeature(_ feature: Feature) throws {
        guard scenarioTester == nil else {
            throw CutwormBDDError.scenarioAlreadyActive
        }

        self.feature = feature
    }

    func beginScenario(name: String) throws {
        guard let feature else {
            throw CutwormBDDError.featureNotActive
        }

        guard scenarioTester == nil else {
            throw CutwormBDDError.scenarioAlreadyActive
        }

        // load scenario from file
        guard let scenario = feature.scenarios.first(where: { $0.name == name }) else {
            throw CutwormBDDError.scenarioNotFound(name: name, feature: feature)
        }

        scenarioTester = ScenarioTester(feature: feature, scenario: scenario)
    }

    func perform(step: Step) throws {
        try activeScenarioTester.perform(step: step)
    }

    func endScenario() throws {
        defer { scenarioTester = nil }

        let result = try activeScenarioTester.finalize()
        resultRepository.store(result: result)

        let unimplementedSteps = result.stepResults
            .filter { $0.status == .notImplemented }
            .map(\.step)
        if !unimplementedSteps.isEmpty {
            throw CutwormBDDError.scenarioIncomplete(result.scenario, unimplementedSteps: unimplementedSteps)
        }
    }

    func receiveTestEvents(_ publisher: AnyPublisher<TestEvent, Never>) {
        testEventCancellable = publisher.sink(receiveValue: { [weak self] event in
            self?.handleEvent(event)
        })
    }

    func handleEvent(_ testEvent: TestEvent) {
        scenarioTester?.handle(event: testEvent)
    }
}

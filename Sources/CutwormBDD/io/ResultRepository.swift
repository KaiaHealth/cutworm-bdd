//
//  ResultRepository.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import Foundation

final class ResultRepository {
    static let shared = ResultRepository()

    private(set) var results = [ScenarioResult]()

    func store(result: ScenarioResult) {
        results.append(result)
    }
}

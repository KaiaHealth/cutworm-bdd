//
//  StepResult.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import Foundation

struct StepResult {
    let step: Step
    let startDate: Date
    let endDate: Date
    let status: Status

    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }
}

extension StepResult: CustomStringConvertible {
    var description: String {
        "\(status) \(step) (\(String(format: "%.2f", duration))s)"
    }
}

//
//  BDDStepChainable.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import Foundation
import XCTest

public protocol BDDStepChainable {}

public extension BDDStepChainable {
    /// Notifies the CutwormBDD that the provided 'Given' step will be performed next.
    ///
    /// - Parameters:
    ///   - name: The step as defined in the Gherkin file. Be sure to exclude the 'Given' keyword and leading whitespace.
    ///
    /// When the provided step is not found, the remaining steps are marked as failed.
    @discardableResult
    func Given(
        _ name: String,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Self {
        assertNoThrow(file: file, line: line) {
            try featureTester.perform(step: Step(type: .given, name: name))
        }
        return self
    }

    /// Notifies the CutwormBDD that the provided 'When' step will be performed next.
    ///
    /// - Parameters:
    ///   - name: The step as defined in the Gherkin file. Be sure to exclude the 'When' keyword and leading whitespace.
    ///
    /// When the provided step is not found, the remaining steps are marked as failed.
    @discardableResult
    func When(
        _ name: String,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Self {
        assertNoThrow(file: file, line: line) {
            try featureTester.perform(step: Step(type: .when, name: name))
        }
        return self
    }

    /// Notifies the CutwormBDD that the provided 'Then' step will be performed next.
    ///
    /// - Parameters:
    ///   - name: The step as defined in the Gherkin file. Be sure to exclude the 'Then' keyword and leading whitespace.
    ///
    /// When the provided step is not found, the remaining steps are marked as failed.
    @discardableResult
    func Then(
        _ name: String,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Self {
        assertNoThrow(file: file, line: line) {
            try featureTester.perform(step: Step(type: .then, name: name))
        }
        return self
    }

    /// Notifies the CutwormBDD that the provided 'And' step will be performed next.
    ///
    /// - Parameters:
    ///   - name: The step as defined in the Gherkin file. Be sure to exclude the 'And' keyword and leading whitespace.
    ///
    /// When the provided step is not found, the remaining steps are marked as failed.
    @discardableResult
    func And(
        _ name: String,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Self {
        assertNoThrow(file: file, line: line) {
            try featureTester.perform(step: Step(type: .and, name: name))
        }
        return self
    }
}

extension BDDStepChainable {
    var featureTester: FeatureTester { .shared }

    func assertNoThrow(
        file: StaticString,
        line: UInt,
        _ closure: () throws -> Void
    ) {
        do {
            try closure()
        } catch {
            XCTFail(error.localizedDescription, file: file, line: line)
            if let error = error as? CutwormBDDError,
                let attachment = XCTAttachment(bddError: error) {
                XCTContext.runActivity(named: "Example code") { activity in
                    activity.add(attachment)
                }
            }
        }
    }
}

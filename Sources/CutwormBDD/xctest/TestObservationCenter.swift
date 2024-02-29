//
//  BDDTestObservationCenter.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import XCTest
import Combine

final class TestObservationCenter: NSObject, XCTestObservation {
    static let shared = TestObservationCenter()

    private let issueSubject = PassthroughSubject<XCTIssue, Never>()

    var issuePublisher: AnyPublisher<XCTIssue, Never> {
        issueSubject.eraseToAnyPublisher()
    }

    init(xcTestObservationCenter: XCTestObservationCenter = .shared) {
        super.init()
        xcTestObservationCenter.addTestObserver(self)
    }

    func testBundleDidFinish(_ testBundle: Bundle) {
        let results = ResultRepository.shared.results
        let targetName = String(testBundle.bundleURL.lastPathComponent.prefix { $0 != "." })
        let currentExecution = TestExecutionInfo(hostName: targetName)
        let exporters: [ResultExporter] = [
            ConsoleResultExporter(),
            FileResultExporter()
        ]
        let resultExportExpectation = XCTestExpectation(description: "Result export completed")
        Task {
            defer { resultExportExpectation.fulfill() }

            for exporter in exporters {
                do {
                    try await exporter.writeResults(results, for: currentExecution)
                } catch {
                    print("Export error: \(error.localizedDescription)")
                }
            }
        }

        XCTWaiter().wait(for: [resultExportExpectation], timeout: 30.0)
    }

    func testCase(_ testCase: XCTestCase, didRecord issue: XCTIssue) {
        issueSubject.send(issue)
    }

    func testCase(_ testCase: XCTestCase, didRecord expectedFailure: XCTExpectedFailure) {
        // No action needed, as expected failures are captured within `testCase(_:didRecord:)` above.
    }
}

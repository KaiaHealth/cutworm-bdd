//
//  SourceCodeTests.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import XCTest
@testable import CutwormBDD

final class SourceCodeTests: XCTestCase {
    func testIndentsInterpolatedMultilineSourceCode() {
        let functionBody: SourceCode = """
            let y = 1
            print(x)
            """

        let code: SourceCode = """
            func test() {
                \(functionBody)
            }
            """

        XCTAssertEqual(
            code.string,
            """
            func test() {
                let y = 1
                print(x)
            }
            """
        )
    }
}

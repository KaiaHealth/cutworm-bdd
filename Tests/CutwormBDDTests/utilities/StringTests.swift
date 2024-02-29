//
//  StringTests.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import XCTest
@testable import CutwormBDD

final class StringTests: XCTestCase {
    func testUpperCamelCased() {
        XCTAssertEqual(
            "email login with valid credentials".upperCamelCased,
            "EmailLoginWithValidCredentials"
        )
    }

    func testIndented() {
        XCTAssertEqual(
            """
            func test() {
                print("hello")
            }
            """
                .indented(with: "    "),
            """
                func test() {
                    print("hello")
                }
            """
        )

        XCTAssertEqual(
            """
            func test() {
                print("hello")
            }
            """
                .indented(with: "    ", excludingFirstLine: true),
            """
            func test() {
                    print("hello")
                }
            """
        )
    }

    func testSuffixWhile() {
        XCTAssertEqual(
            "test123".suffix(while: { $0.isNumber }),
            "123"
        )
        XCTAssertEqual(
            "test123".suffix(while: { _ in false }),
            ""
        )
        XCTAssertEqual(
            "test123".suffix(while: { _ in true }),
            "test123"
        )
    }
}

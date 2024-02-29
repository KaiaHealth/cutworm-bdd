//
//  CodeGenerationTests.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import XCTest
@testable import CutwormBDD

final class CodeGenerationTests: XCTestCase {
    func testGenerateFeature() {
        XCTAssertEqual(
            Feature.mock().swiftCode.string,
            """
            import XCTest
            import CutwormBDD

            final class AuthenticationTests: XCTestCase, BDDTestCase {

                override func setUp() {
                    super.setUp()

                    Feature("Authentication")
                }

                func testLogIn() {
                    Scenario("Log in")
                    Given("the user has an account")

                    When("the user enters their password")

                    Then("the user is logged in")

                }
            }
            """
        )
    }

    func testGenerateScenario() {
        func test() {
            XCTAssertEqual(
                Scenario.mock().swiftCode.string,
                """
                func testLogIn() {
                    Scenario("Log in")
                    Given("the user has an account")

                    When("the user enters their password")

                    Then("the user is logged in")

                }
                """
            )
        }
    }
}

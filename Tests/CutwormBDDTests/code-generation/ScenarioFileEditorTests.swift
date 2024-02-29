//
//  ScenarioFileEditorTests.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import XCTest
@testable import CutwormBDD

final class ScenarioFileEditorTests: XCTestCase {
    func testReplacesGenerateScenarioFunction() throws {
        let editor = ScenarioFileEditor(
            scenario: .mock(),
            insertAtLine: 17 /* the line where `GenerateScenario_EXPERIMENTAL` is called */
        )
        let editedFile = try editor.performEdits(
            contents: """
            //
            //  AuthenticationTests.swift
            //  CutwormBDDDemo
            //

            import XCTest
            import CutwormBDD

            final class AuthenticationTests: XCTestCase, BDDTestCase {
                override func setUp() {
                    super.setUp()

                    Feature("Authentication", in: .module)
                }

                func test() {
                    GenerateScenario_EXPERIMENTAL("Email login with valid credentials")
                }
            }
            """
        )

        XCTAssertEqual(
            editedFile,
            """
            //
            //  AuthenticationTests.swift
            //  CutwormBDDDemo
            //

            import XCTest
            import CutwormBDD

            final class AuthenticationTests: XCTestCase, BDDTestCase {
                override func setUp() {
                    super.setUp()

                    Feature("Authentication", in: .module)
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
}

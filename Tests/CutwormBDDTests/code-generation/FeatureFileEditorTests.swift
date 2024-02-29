//
//  FeatureFileEditorTests.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import XCTest
@testable import CutwormBDD

final class FeatureFileEditorTests: XCTestCase {
    func testPreservesHeaderComment() throws {
        let editor = FeatureFileEditor(feature: .mock())
        let editedFile = try editor.performEdits(
            contents: """
            //
            //  AuthenticationTests.swift
            //  CutwormBDDDemo
            //

            import XCTest
            import CutwormBDD

            final class AuthenticationTests: XCTestCase, BDDTestCase {
                func test() {
                    GenerateFeature_EXPERIMENTAL("Authentication")
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
}

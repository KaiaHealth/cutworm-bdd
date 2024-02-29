//
//  FeatureParserTests.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import XCTest
@testable import CutwormBDD

final class FeatureParserTests: XCTestCase {
    func testParseText() throws {
        let featureFileContents = """
        # language: en
        Feature: Authentication

            As a user, I want to be able to reliably log into my account

            Background:
                Given the app is in initial state with no user logged in

            @AUTOMATED @APP-US @APP-UK @APP-IT
            Scenario Outline: Email login with valid credentials
                Given the user with email test@test.com and password 123456 exists
                When the user attempts to log in with email test@test.com and password 123456 exists
                Then the user is successfully logged in

                Examples:
                  | email                         | password |
                  | ignore_me@ignore.com          | 12345678 |

            @AUTOMATED @APP-US @APP-UK @APP-IT
            Scenario: Email login with invalid password
                Given the user has an account with the email test@test.com
                  And the user's password is not 123456
                 When the user attempts to log in with email test@test.com and password 123456
                 Then the user is not logged in
                  And the user is informed that their login attempt failed
        """

        let expectedFeature = Feature(
            name: "Authentication",
            scenarios: [
                Scenario(
                    name: "Email login with valid credentials",
                    steps: [
                        Step(type: .given, name: "the user with email test@test.com and password 123456 exists"),
                        Step(type: .when, name: "the user attempts to log in with email test@test.com and password 123456 exists"),
                        Step(type: .then, name: "the user is successfully logged in")
                    ]
                ),
                Scenario(
                    name: "Email login with invalid password",
                    steps: [
                        Step(type: .given, name: "the user has an account with the email test@test.com"),
                        Step(type: .and, name: "the user's password is not 123456"),
                        Step(type: .when, name: "the user attempts to log in with email test@test.com and password 123456"),
                        Step(type: .then, name: "the user is not logged in"),
                        Step(type: .and, name: "the user is informed that their login attempt failed")
                    ]
                )
            ]
        )

        let feature = try FeatureParser.parse(text: featureFileContents)
        XCTAssertEqual(feature, expectedFeature)
    }

    func testParseHandlesWindowsNewlines() throws {
        let featureContents = "Feature: Authentication\nScenario: Test\r\nGiven test"

        let feature = try FeatureParser.parse(text: featureContents)
        XCTAssertEqual(feature, Feature(name: "Authentication", scenarios: [Scenario(name: "Test", steps: [Step(type: .given, name: "test")])]))
    }

    func testThrowsErrorWhenScenarioIsInvalid() {
        let featureFileContents = """
        # language: en
        Feature: Authentication

            As a user, I want to be able to reliably log into my account

            Background:
                Given the app is in initial state with no user logged in

            @AUTOMATED @APP-US @APP-UK @APP-IT
            Scenario Steps: Email login with valid credentials
                Given the user with email test@test.com and password 123456 exists
                When the user attempts to log in with email test@test.com and password 123456 exists
                Then the user is successfully logged in

                Examples:
                  | email                         | password |
                  | ignore_me@ignore.com          | 12345678 |
        """

        XCTAssertThrowsError(try FeatureParser.parse(text: featureFileContents)) { error in
            guard let error = error as? CutwormBDDError else {
                XCTFail("Expected a CutwormBDDError")
                return
            }

            guard case .scenarioInvalid = error else {
                XCTFail("Unexpected error type: \(error)")
                return
            }
        }
    }
}

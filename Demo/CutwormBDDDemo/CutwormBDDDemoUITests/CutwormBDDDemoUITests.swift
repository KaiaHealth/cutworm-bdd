//
//  CutwormBDDDemoUITests.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import XCTest
import CutwormBDD

final class AuthenticationTests: XCTestCase, BDDTestCase {
    override func setUp() {
        super.setUp()

        Feature("Authentication")
    }

    func testEmailLoginWithValidCredentials() {
        Scenario("Email login with valid credentials")

        let app = XCUIApplication()
        app.launch()
        let emailTextField = app.textFields["emailTextField"]
        let passwordSecureField = app.secureTextFields["passwordTextField"]

        Given("the user has an account")
        let validUser = (email: "user@example.com", password: "valid")

        When("the user attempts to log in with their credentials")
        emailTextField.tap()
        emailTextField.typeText(validUser.email)
        passwordSecureField.tap()
        passwordSecureField.typeText(validUser.password)
        app.buttons["loginButton"].tap()

        Then("the user is successfully logged in")
        XCTAssertTrue(app.staticTexts["homeScreenTitle"].exists)
    }

    func testEmailLoginWithInvalidPassword() {
        Scenario("Email login with invalid password")

        let app = XCUIApplication()
        app.launch()
        let emailTextField = app.textFields["emailTextField"]
        let passwordSecureField = app.secureTextFields["passwordTextField"]

        Given("the user has an account")
        let invalidUser = (email: "user@example.com", password: "wrongPassword")

        When("the user attempts to log in with their email and an invalid password")
        emailTextField.tap()
        emailTextField.typeText(invalidUser.email)
        passwordSecureField.tap()
        passwordSecureField.typeText(invalidUser.password)
        app.buttons["loginButton"].tap()

        Then("the user is not logged in")
        XCTAssertFalse(app.staticTexts["homeScreenTitle"].exists)

        And("the user is informed that their login attempt failed")
        XCTAssertTrue(app.alerts["Login Failed"].exists, "The login failed alert did not appear.")
    }
}

# `CutwormBDD`

[![SwiftPM](https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat)](https://swift.org/package-manager/) [![License](https://img.shields.io/badge/License-Apache-blue)](https://github.com/KaiaHealth/cutworm-bdd/blob/main/LICENSE) [![Platform](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FKaiaHealth%2Fcutworm-bdd%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/KaiaHealth/cutworm-bdd) [![Swift Versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FKaiaHealth%2Fcutworm-bdd%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/KaiaHealth/cutworm-bdd)

A native, lightweight BDD testing library for Swift/XCTest.

CutwormBDD connects high-level [Gherkin](https://cucumber.io/docs/gherkin/reference/) feature specifications with tests.

BDD capabilities are added through annotation-like function calls inserted within a test. When a test is run, Cutworm validates that the test fulfilled the Gherkin scenario and records the result.

Unlike Cucumber frameworks, Cutworm does not require splitting tests into independent steps, nor controls test execution. As a result, adapting existing tests is easy and Cutworm plays well with Xcode.

## Getting Started

To get a feel for how Cutworm works, open the CutwormBDDDemo project in Xcode and run the tests.

### Adding a test

First, create a directory named `features` in your test target that contains the Gherkin feature definitions.

`features/authentication.feature`

```cucumber
Feature: Authentication

    As a user, I want to be able to reliably log into my account

    Scenario: Email login with valid credentials
        Given the user has an account
        When the user attempts to log in with their credentials
        Then the user is successfully logged in
```

For Swift packages, the test target should be set up with a dependency to CutwormBDD and the features in resources:

```swift
.testTarget(
    name: "MyTests",
    dependencies: ["CutwormBDD"],
    resources: [.copy("features")]
),
```

Next, create a test case for a feature, and run the test once to generate the BDD template:

```swift
class AuthenticationTests: XCTestCase, BDDTestCase {
    override func setUp() {
        super.setUp()

        // Informs Cutworm which feature is under test
        Feature("Authentication", in: .module)
    }

    func testLogin() throws {
        // When executed, this replaces the body of `testLogin` with a BDD template.
        GenerateScenario_EXPERIMENTAL("Email login with valid credentials")
    }
}
```

Now that the template is generated, you can write your test, breaking down the parts of the test into steps:

```swift
class AuthenticationTests: XCTestCase, BDDTestCase {
    override func setUp() {
        super.setUp()

        // Informs Cutworm which feature is under test
        Feature("Authentication", in: .module)
    }

    func testLogin() throws {
        Scenario("Email login with valid credentials")

        Given("the user has an account")
        // If an assertion failure occurs, or uncaught error is thrown during a step,
        // the step is failed and the scenario is consider failed.
        let user = try makeTestUser()

        When("the user attempts to log in with their credentials")
        loginScreen.typeCredentials(username: user.username, password: user.password)

        let result = loginScreen.submit()

        Then("the user is successfully logged in")

        XCTAssertEqual(result, .success)
    }
}
```

Finally, run the tests. You'll see the BDD results printed in the Console, and exported to a JSON file:

```
Exporting BDD results for MyTests...
Feature: Authentication
Scenario: Email login with valid credentials
Steps:
✅ given the user has an account (0.00s)
✅ when the user attempts to log in with their credentials (0.00s)
✅ then the user is successfully logged in (0.00s)

Writing results to JSON file...
BDD result JSON is saved at path ...json
```

In case the second step failed, the results would look like this:

```
Feature: Authentication
Scenario: Email login with valid credentials
Steps:
✅ given the user has an account (0.00s)
❌ when the user attempts to log in with their credentials (0.04s)
⏩ then the user is successfully logged in (0.00s)
```

## Contributing

We always appreciate contributions from the community. To make changes to the project, you can clone the repo and open the folder in Xcode. Once you've made your changes, you can run the tests to ensure everything is working as expected and submit a pull request.

See the [open issues](https://github.com/KaiaHealth/cutworm-bdd/issues?q=is:issue+is:open+sort:updated-desc) for a list of proposed features (and known issues).

## Limitations

- Some Gherkin constructs are not yet supported, including `Scenario Outline`, `Examples`, `Background`, `Rule`, and tags.
- Export is currently only to a JSON file. This can be limiting with some real device testing providers if they don't provide access to the file.

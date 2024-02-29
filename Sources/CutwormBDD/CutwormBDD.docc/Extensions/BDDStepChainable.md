# ``BDDStepChainable``

Allows chaining BDD steps inside a test to provide a natural reading experience.

If your system under test allows chaining actions or assertions as in the page-object model,
you can proceed to the next BDD step by using the respective `BDDStepChainable` method.

```swift
func testUserLogin() {
    Scenario("Email login with valid credentials")

    Given("the user has an account")
    LoginFeature
        .makeTestUser()
        .When("the user attempts to log in with their credentials")
        .attemptLogin()
        .Then("the user is successfully logged in")
        .assertIsLoggedIn()
}
```

## Notes

No implementation is required, as the default implementation is provided by the protocol extension.

Conform to ``BDDTestCase`` in your test case instead of ``BDDStepChainable``,
as it already inherits from ``BDDStepChainable`` and ``BDDStepChainable`` is of no use outside of a BDD test case.

## Topics

- ``BDDStepChainable/Given(_:file:line:)``
- ``BDDStepChainable/When(_:file:line:)``
- ``BDDStepChainable/Then(_:file:line:)``
- ``BDDStepChainable/And(_:file:line:)``

# ``BDDTestCase``

Give BDD superpowers to your test cases.

Simply conform to ``BDDTestCase`` in your `XCTestCase` instance to enable access to BDD features, scenarios, and steps in your Gherkin files.
Use code generation to create BDD templates for your test cases.

## Topics

### Performing a BDD scenario

- ``Feature(_:in:file:line:)``
- ``Scenario(_:file:line:)``
- ``EndScenario(file:line:)``

### Code generation (experimental)

- ``GenerateFeature_EXPERIMENTAL(_:in:file:line:)``
- ``GenerateScenario_EXPERIMENTAL(_:file:line:)``

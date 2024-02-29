Feature: Authentication

    As a user, I want to be able to reliably log into my account

    Scenario: Email login with valid credentials
        Given the user has an account
        When the user attempts to log in with their credentials
        Then the user is successfully logged in

    Scenario: Email login with invalid password
        Given the user has an account
         When the user attempts to log in with their email and an invalid password
         Then the user is not logged in
          And the user is informed that their login attempt failed

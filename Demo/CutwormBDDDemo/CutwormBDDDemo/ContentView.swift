//
//  ContentView.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import SwiftUI

public struct ContentView: View {
    public init() {}

    @State private var email = ""
    @State private var password = ""
    @State private var showingHomeScreen = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    public var body: some View {
        NavigationView {
            VStack {
                TextField("Email", text: $email)
                    .padding()
                    .accessibilityIdentifier("emailTextField")
                SecureField("Password", text: $password)
                    .padding()
                    .accessibilityIdentifier("passwordTextField")
                Button("Login") {
                    loginAction()
                }
                .accessibilityIdentifier("loginButton")
                .padding()
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Login Failed"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .navigationTitle("Login")
        .fullScreenCover(isPresented: $showingHomeScreen) {
            HomeScreen()
        }
    }

    func loginAction() {
        if password == "valid" {
            self.showingHomeScreen = true
        } else {
            self.alertMessage = "Your email or password is incorrect. Please try again."
            self.showingAlert = true
        }
    }
}

struct HomeScreen: View {
    var body: some View {
        Text("Welcome, You're logged in!")
            .accessibilityIdentifier("homeScreenTitle")
    }
}

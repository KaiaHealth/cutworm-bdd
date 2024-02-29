//
//  ResultJSONBuilderTests.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import XCTest
@testable import CutwormBDD

final class ResultJSONBuilderTests: XCTestCase {
    func test() throws {
        let data = try ResultJSONBuilder.build(from: [ScenarioResult.mock()])
        let json = try XCTUnwrap(String(data: data, encoding: .utf8))

        XCTAssertEqual(
            json,
            """
            [
              {
                "description" : "Authentication",
                "elements" : [
                  {
                    "description" : "Log in",
                    "id" : "Log in",
                    "keyword" : "Scenario",
                    "name" : "Log in",
                    "steps" : [
                      {
                        "keyword" : "given",
                        "name" : "the user has an account",
                        "result" : {
                          "duration" : 1000000000,
                          "status" : "passed"
                        }
                      },
                      {
                        "keyword" : "when",
                        "name" : "the user enters their password",
                        "result" : {
                          "duration" : 2000000000,
                          "status" : "failed"
                        }
                      },
                      {
                        "keyword" : "then",
                        "name" : "the user is logged in",
                        "result" : {
                          "duration" : 0,
                          "status" : "failed"
                        }
                      }
                    ],
                    "type" : "scenario"
                  }
                ],
                "id" : "Authentication",
                "keyword" : "Feature",
                "name" : "Authentication",
                "uri" : ""
              }
            ]
            """
        )
    }
}

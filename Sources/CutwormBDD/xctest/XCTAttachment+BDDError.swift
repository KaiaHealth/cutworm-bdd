//
//  XCTAttachment+BDDError.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import XCTest
import UniformTypeIdentifiers

extension XCTAttachment {
    convenience init?(bddError: CutwormBDDError) {
        guard let code = bddError.suggestedSwiftCode else { return nil }

        let data = code.string.data(using: .utf8)!
        self.init(data: data, uniformTypeIdentifier: UTType.swiftSource.identifier)
        name = "Test.swift"
    }
}

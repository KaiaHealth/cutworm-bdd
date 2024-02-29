//
//  Step.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import Foundation

struct Step: Equatable {
    let type: StepType
    let name: String
}

extension Step: CustomStringConvertible {
    var description: String { "\(type) \(name)" }
}

extension Step: SwiftRepresentable {
    var swiftCode: SourceCode {
        """
        \(type.rawValue)("\(name)")
        """
    }
}

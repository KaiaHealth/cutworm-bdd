//
//  Status.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import Foundation

enum Status {
    case success
    case failure
    case skipped
    case notImplemented
}

extension Status: CustomStringConvertible {
    var description: String {
        switch self {
        case .success:
            return "✅"
        case .failure:
            return "❌"
        case .skipped:
            return "⏩"
        case .notImplemented:
            return "🚧"
        }
    }
}

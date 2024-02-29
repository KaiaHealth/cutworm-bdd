//
//  StringProtocol+Indentation.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import Foundation

extension StringProtocol {
    func indented(with indentation: String, excludingFirstLine: Bool = false) -> String {
        var output = String()
        output.reserveCapacity(count)
        let lines = split(separator: "\n", omittingEmptySubsequences: false)
        for (index, line) in lines.enumerated() {
            if index != lines.startIndex || !excludingFirstLine, !line.isEmpty {
                output.append(indentation)
            }
            output.append(String(line))

            if index != lines.endIndex - 1 {
                output.append("\n")
            }
        }
        return output
    }
}

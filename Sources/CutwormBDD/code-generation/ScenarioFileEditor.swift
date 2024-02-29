//
//  ScenarioFileEditor.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import Foundation

struct ScenarioFileEditor: FileEditor {
    let scenario: Scenario
    let insertAtLine: Int

    func performEdits(contents: String) throws -> String {
        var lines = contents.split(separator: "\n", omittingEmptySubsequences: false).map { String($0) }
        let lineIndex = Int(insertAtLine) - 1

        // Find the function declaration that should be replaced
        let functionDeclarationStartLine = lines.prefix(through: lineIndex).lastIndex(where: { $0.contains("func test") })
        let functionDeclarationEndLine = lines.suffix(from: lineIndex).firstIndex(where: { $0.contains("}") })

        guard let functionDeclarationStartLine, let functionDeclarationEndLine else {
            fatalError("Couldn't identify function to replace.")
        }

        // Determine the indentation of the old function, to use for the new one
        let indentation = String(lines[functionDeclarationStartLine].prefix(while: { $0.isWhitespace }))

        // Remove the old function declaration
        for line in (functionDeclarationStartLine...functionDeclarationEndLine).reversed() {
            lines.remove(at: line)
        }

        // Insert new function declaration
        let generatedCode = scenario.swiftCode.string.indented(with: indentation)
        lines.insert(generatedCode, at: functionDeclarationStartLine)

        return lines.joined(separator: "\n")
    }
}

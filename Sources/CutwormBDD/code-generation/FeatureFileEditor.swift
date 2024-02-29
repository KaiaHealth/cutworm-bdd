//
//  FeatureFileEditor.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import Foundation

struct FeatureFileEditor: FileEditor {
    let feature: Feature

    func performEdits(contents: String) throws -> String {
        var components = contents
            .split(separator: "\n", omittingEmptySubsequences: false)
            // Preserve file header comment from the original file
            .prefix(while: {
                $0.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty ||
                $0.hasPrefix("//")
            })
            .map { String($0) }

        components.append(feature.swiftCode.string)

        return components.joined(separator: "\n")
    }
}

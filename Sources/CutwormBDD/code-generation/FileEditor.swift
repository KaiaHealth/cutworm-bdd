//
//  FileEditor.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import Foundation

protocol FileEditor {
    func performEdits(atPath path: String) throws
    func performEdits(contents: String) throws -> String
}

extension FileEditor {
    func performEdits(atPath path: String) throws {
        let fileContents = try String(contentsOfFile: path, encoding: .utf8)
        let updatedContents = try performEdits(contents: fileContents)
        try updatedContents.write(toFile: path, atomically: true, encoding: .utf8)
    }
}

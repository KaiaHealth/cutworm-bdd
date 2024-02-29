//
//  ResultExporter.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import Foundation

protocol ResultExporter {
    func writeResults(_ results: [ScenarioResult], for execution: TestExecutionInfo) async throws
}

final class FileResultExporter: ResultExporter {
    enum ExportError: Error {
        case jsonWriteError(Error)
        case pathNotFoundError
    }

    func writeResults(_ results: [ScenarioResult], for execution: TestExecutionInfo) async throws {
        print("Writing results to JSON file...")

        let jsonData = try ResultJSONBuilder.build(from: results)
        guard let documentsFolderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { throw ExportError.pathNotFoundError }
        let fileName = ResultJSONBuilder.fileName(from: execution)
        let writeToPath = URL(fileURLWithPath: documentsFolderURL.path, isDirectory: true)
            .appendingPathComponent(fileName)
        do {
            try jsonData.write(to: writeToPath)
        } catch {
            throw ExportError.jsonWriteError(error)
        }
        print("BDD result JSON is saved at path \(writeToPath.absoluteString)")
    }
}

final class ConsoleResultExporter: ResultExporter {
    func writeResults(_ results: [ScenarioResult], for execution: TestExecutionInfo) async throws {
        print("Exporting BDD results for \(execution.hostName)...")
        for result in results {
            print("\(result)\n")
        }
    }
}

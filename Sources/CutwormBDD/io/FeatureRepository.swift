//
//  FeatureRepository.swift
//  Copyright © 2023 kaia health software GmbH. Licensed under Apache License v2.0.
//

import Foundation

struct FeatureRepository {
    private static var repositories: [Bundle: FeatureRepository] = [:]
    private var features: [Feature] = []

    static func repository(for bundle: Bundle) throws -> Self {
        if let repository = repositories[bundle] {
            return repository
        }

        let repository = try FeatureRepository(testBundle: bundle)
        repositories[bundle] = repository
        return repository
    }

    private init() {
        // This unit should only be used via `repository(for:)` static method.
    }

    private init(testBundle: Bundle) throws {
        features = try readFromFeaturesFolder(in: testBundle)
    }

    func getFeature(_ name: String) throws -> Feature {
        guard let feature = features.first(where: { $0.name == name }) else {
            throw CutwormBDDError.featureNotFound(name: name)
        }

        return feature
    }

    private func readFromFeaturesFolder(in testBundle: Bundle) throws -> [Feature] {
        guard let featuresURL = testBundle.url(forResource: "features", withExtension: nil) else {
            throw CutwormBDDError.featuresDirectoryNotFound(bundle: testBundle)
        }

        let allFeatures = try featureFiles(at: featuresURL).map { url in
            let string = try String(contentsOf: url, encoding: .utf8)
            return try FeatureParser.parse(text: string)
        }
        // Check if there are features with the same name in different files
        let featuresByName = Dictionary(grouping: allFeatures, by: \.name)

        if allFeatures.count != featuresByName.count {
            let duplicatedFeatureNames = featuresByName.filter { $0.value.count > 1 }.map(\.key)
            throw CutwormBDDError.duplicatedFeaturesFound(names: duplicatedFeatureNames)
        } else {
            return allFeatures
        }
    }

    private func featureFiles(at featuresURL: URL) -> [URL] {
        let enumerator: FileManager.DirectoryEnumerator? = FileManager.default.enumerator(at: featuresURL, includingPropertiesForKeys: nil)
        var fileList = [URL]()
        while let url = enumerator?.nextObject() as? URL {
            if url.pathExtension == "feature" {
                fileList.append(url)
            }
        }
        return fileList.sorted { $0.absoluteString < $1.absoluteString }
    }
}

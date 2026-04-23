//
//  PhotoFileStore.swift
//  BufalloSteaklovers
//

import Foundation

enum PhotoFileStore {
    private static let subdir = "SteakPhotos"

    private static var directoryURL: URL {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return base.appendingPathComponent(subdir, isDirectory: true)
    }

    static func ensureDirectory() {
        try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    }

    /// Saves JPEG/PNG data; returns stable filename (`uuid.jpg`).
    static func saveImageData(_ data: Data) throws -> String {
        ensureDirectory()
        let name = UUID().uuidString + ".img"
        let url = directoryURL.appendingPathComponent(name)
        try data.write(to: url, options: .atomic)
        return name
    }

    static func loadImageData(filename: String) -> Data? {
        let url = directoryURL.appendingPathComponent(filename)
        return try? Data(contentsOf: url)
    }

    static func deleteImage(filename: String) {
        let url = directoryURL.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: url)
    }
}

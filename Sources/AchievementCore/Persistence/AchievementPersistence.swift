import Foundation

public struct AchievementPersistence: Sendable {
    public let fileURL: URL

    public init(directoryURL: URL? = nil, fileName: String = "achievement_state.json") {
        if let directoryURL {
            self.fileURL = directoryURL.appendingPathComponent(fileName)
        } else {
            #if os(iOS) || os(macOS)
            let defaultDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            #else
            let defaultDirectory = FileManager.default.temporaryDirectory
            #endif
            self.fileURL = defaultDirectory
                .appendingPathComponent(fileName)
        }
    }

    public func load() throws -> AchievementState {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return AchievementState()
        }
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(AchievementState.self, from: data)
    }

    public func save(_ state: AchievementState) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(state)
        let directory = fileURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        try data.write(to: fileURL, options: [.atomic])
    }
}

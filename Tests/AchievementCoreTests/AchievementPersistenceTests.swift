import XCTest
@testable import AchievementCore

final class AchievementPersistenceTests: XCTestCase {
    func testSaveAndLoadState() throws {
        var state = AchievementState()
        let achievement = Achievement(
            title: "Read a Book",
            detail: "Read for 20 minutes",
            icon: .system("book.fill"),
            points: 10,
            category: "Learning",
            schedule: .daily
        )
        state.addAchievement(achievement)
        state.logCompletion(for: achievement.id, on: Date(), calendar: .current)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let persistence = AchievementPersistence(directoryURL: tempURL)
        try persistence.save(state)

        let loaded = try persistence.load()
        XCTAssertEqual(loaded.achievements.count, 1)
        XCTAssertEqual(loaded.completions.count, 1)
    }
}

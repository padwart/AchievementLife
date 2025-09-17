import XCTest
@testable import AchievementCore

final class AchievementStateTests: XCTestCase {
    private let calendar = Calendar(identifier: .gregorian)

    func testToggleCompletionAddsAndRemoves() {
        let achievement = makeSampleAchievement()
        var state = AchievementState(achievements: [achievement])
        let today = calendar.startOfDay(for: Date())
        XCTAssertFalse(state.isCompleted(achievement.id, on: today, calendar: calendar))
        state.toggleCompletion(for: achievement.id, on: today, calendar: calendar)
        XCTAssertTrue(state.isCompleted(achievement.id, on: today, calendar: calendar))
        state.toggleCompletion(for: achievement.id, on: today, calendar: calendar)
        XCTAssertFalse(state.isCompleted(achievement.id, on: today, calendar: calendar))
    }

    func testStatistics() {
        let achievement = makeSampleAchievement()
        var state = AchievementState(achievements: [achievement])
        let start = makeDate(year: 2024, month: 4, day: 1)
        let end = makeDate(year: 2024, month: 4, day: 7)
        let interval = DateInterval(start: start, end: end)
        state.logCompletion(for: achievement.id, on: start, calendar: calendar)
        state.logCompletion(for: achievement.id, on: makeDate(year: 2024, month: 4, day: 3), calendar: calendar)
        let stats = state.statistics(for: interval, calendar: calendar)
        XCTAssertEqual(stats.totalAchievements, 1)
        XCTAssertEqual(stats.completedAchievements, 2)
        XCTAssertGreaterThan(stats.totalPointsEarned, 0)
        XCTAssertEqual(stats.completionHistory.count, 7)
    }

    func testUpcomingOccurrences() {
        let achievement = makeSampleAchievement()
        let state = AchievementState(achievements: [achievement])
        let occurrences = state.upcomingOccurrences(for: achievement.id, from: Date(), calendar: calendar)
        XCTAssertFalse(occurrences.isEmpty)
    }

    private func makeSampleAchievement() -> Achievement {
        Achievement(
            title: "Gym Session",
            detail: "Complete a strength workout",
            icon: .system("dumbbell.fill"),
            points: 20,
            category: "Fitness",
            schedule: .weekly([.monday, .wednesday, .friday])
        )
    }

    private func makeDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.calendar = calendar
        components.year = year
        components.month = month
        components.day = day
        return calendar.date(from: components) ?? Date()
    }
}

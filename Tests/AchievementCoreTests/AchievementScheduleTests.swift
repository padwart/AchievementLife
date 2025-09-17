import XCTest
@testable import AchievementCore

final class AchievementScheduleTests: XCTestCase {
    private let calendar = Calendar(identifier: .gregorian)

    func testDailyScheduleIsAlwaysDue() {
        let schedule = AchievementSchedule.daily
        let today = Date()
        XCTAssertTrue(schedule.isDue(on: today, calendar: calendar))
    }

    func testWeeklyScheduleMatchesSelectedDays() {
        let schedule = AchievementSchedule.weekly([.monday, .wednesday])
        let monday = makeDate(year: 2024, month: 3, day: 4)
        let tuesday = makeDate(year: 2024, month: 3, day: 5)
        XCTAssertTrue(schedule.isDue(on: monday, calendar: calendar))
        XCTAssertFalse(schedule.isDue(on: tuesday, calendar: calendar))
    }

    func testMonthlyScheduleMatchesDays() {
        let schedule = AchievementSchedule.monthly([1, 15])
        let first = makeDate(year: 2024, month: 4, day: 1)
        let second = makeDate(year: 2024, month: 4, day: 10)
        XCTAssertTrue(schedule.isDue(on: first, calendar: calendar))
        XCTAssertFalse(schedule.isDue(on: second, calendar: calendar))
    }

    func testSpecificDatesSchedule() {
        let components = [DateComponents(year: 2024, month: 12, day: 25)]
        let schedule = AchievementSchedule.specificDates(components)
        let match = makeDate(year: 2024, month: 12, day: 25)
        let miss = makeDate(year: 2024, month: 12, day: 26)
        XCTAssertTrue(schedule.isDue(on: match, calendar: calendar))
        XCTAssertFalse(schedule.isDue(on: miss, calendar: calendar))
    }

    func testCustomIntervalSchedule() {
        let anchor = makeDate(year: 2024, month: 1, day: 1)
        let schedule = AchievementSchedule.customInterval(days: 3, anchorDate: anchor)
        let due = makeDate(year: 2024, month: 1, day: 7)
        let notDue = makeDate(year: 2024, month: 1, day: 8)
        XCTAssertTrue(schedule.isDue(on: due, calendar: calendar))
        XCTAssertFalse(schedule.isDue(on: notDue, calendar: calendar))
    }

    func testNextOccurrencesForWeeklySchedule() {
        let schedule = AchievementSchedule.weekly([.monday, .friday])
        let start = makeDate(year: 2024, month: 3, day: 5) // Tuesday
        let occurrences = schedule.nextOccurrences(from: start, limit: 3, calendar: calendar)
        XCTAssertEqual(occurrences.count, 3)
        XCTAssertEqual(calendar.component(.weekday, from: occurrences[0]), Weekday.friday.rawValue)
        XCTAssertEqual(calendar.component(.weekday, from: occurrences[1]), Weekday.monday.rawValue)
    }

    private func makeDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.calendar = calendar
        return calendar.date(from: components) ?? Date()
    }
}

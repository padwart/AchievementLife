import Foundation

public struct AchievementState: Codable, Sendable {
    public private(set) var achievements: [Achievement]
    public private(set) var completions: [AchievementCompletion]

    public init(achievements: [Achievement] = [], completions: [AchievementCompletion] = []) {
        self.achievements = achievements
        self.completions = completions.sorted(by: { $0.completedAt < $1.completedAt })
    }

    public mutating func addAchievement(_ achievement: Achievement) {
        achievements.append(achievement)
    }

    public mutating func updateAchievement(_ achievement: Achievement) {
        guard let index = achievements.firstIndex(where: { $0.id == achievement.id }) else { return }
        achievements[index] = achievement
    }

    public mutating func removeAchievement(id: Achievement.ID) {
        achievements.removeAll { $0.id == id }
        completions.removeAll { $0.achievementID == id }
    }

    public mutating func toggleCompletion(
        for achievementID: Achievement.ID,
        on date: Date = Date(),
        calendar: Calendar = .current
    ) {
        if let existing = completion(on: date, for: achievementID, calendar: calendar) {
            completions.removeAll { $0.id == existing.id }
        } else {
            logCompletion(for: achievementID, on: date, calendar: calendar)
        }
    }

    @discardableResult
    public mutating func logCompletion(
        for achievementID: Achievement.ID,
        on date: Date = Date(),
        calendar: Calendar = .current
    ) -> AchievementCompletion? {
        guard achievements.contains(where: { $0.id == achievementID }) else { return nil }
        let normalized = calendar.startOfDay(for: date)
        let points = achievements.first(where: { $0.id == achievementID })?.points ?? 0
        let completion = AchievementCompletion(achievementID: achievementID, completedAt: normalized, pointsEarned: points)
        completions.append(completion)
        completions.sort(by: { $0.completedAt < $1.completedAt })
        return completion
    }

    public func completion(on date: Date, for achievementID: Achievement.ID, calendar: Calendar = .current) -> AchievementCompletion? {
        let target = calendar.startOfDay(for: date)
        return completions.first(where: { $0.achievementID == achievementID && calendar.isDate($0.completedAt, inSameDayAs: target) })
    }

    public func isCompleted(_ achievementID: Achievement.ID, on date: Date = Date(), calendar: Calendar = .current) -> Bool {
        completion(on: date, for: achievementID, calendar: calendar) != nil
    }

    public func achievementsDue(on date: Date, calendar: Calendar = .current) -> [Achievement] {
        achievements.filter { !$0.isArchived && $0.schedule.isDue(on: date, calendar: calendar) }
    }

    public func statistics(for range: DateInterval, calendar: Calendar = .current) -> AchievementStatistics {
        let relevantCompletions = completions.filter { range.contains($0.completedAt) }
        let totalAchievements = achievements.filter { !$0.isArchived }.count
        let completedToday = relevantCompletions.count
        let completionRate: Double
        if totalAchievements == 0 {
            completionRate = 0
        } else {
            let days = max(1, calendar.dateComponents([.day], from: range.start, to: range.end).day ?? 1)
            completionRate = Double(completedToday) / Double(totalAchievements * days)
        }
        let totalPoints = relevantCompletions.reduce(0) { $0 + $1.pointsEarned }
        let history = buildHistory(range: range, completions: relevantCompletions, calendar: calendar)
        let streaks = calculateStreaks(range: range, completions: relevantCompletions, calendar: calendar)
        let weekdayBreakdown = Dictionary(grouping: relevantCompletions) { completion -> Weekday in
            let weekdayValue = calendar.component(.weekday, from: completion.completedAt)
            return Weekday(rawValue: weekdayValue) ?? .monday
        }.mapValues { $0.count }
        let categoryBreakdown = Dictionary(grouping: relevantCompletions) { completion -> String in
            achievements.first(where: { $0.id == completion.achievementID })?.category ?? "General"
        }.mapValues { $0.count }

        return AchievementStatistics(
            totalAchievements: totalAchievements,
            completedAchievements: completedToday,
            completionRate: completionRate,
            totalPointsEarned: totalPoints,
            currentStreak: streaks.current,
            bestStreak: streaks.best,
            completionsByWeekday: weekdayBreakdown,
            completionHistory: history,
            categoryBreakdown: categoryBreakdown
        )
    }

    public func upcomingOccurrences(for achievementID: Achievement.ID, from startDate: Date, limit: Int = 5, calendar: Calendar = .current) -> [Date] {
        guard let achievement = achievements.first(where: { $0.id == achievementID }) else { return [] }
        return achievement.schedule.nextOccurrences(from: startDate, limit: limit, calendar: calendar)
    }

    private func buildHistory(range: DateInterval, completions: [AchievementCompletion], calendar: Calendar) -> [Date: Int] {
        var history: [Date: Int] = [:]
        var currentDate = calendar.startOfDay(for: range.start)
        while currentDate <= range.end {
            history[currentDate] = 0
            guard let next = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = next
        }
        for completion in completions {
            let day = calendar.startOfDay(for: completion.completedAt)
            history[day, default: 0] += 1
        }
        return history
    }

    private func calculateStreaks(range: DateInterval, completions: [AchievementCompletion], calendar: Calendar) -> (current: Int, best: Int) {
        let days = completions.map { calendar.startOfDay(for: $0.completedAt) }.sorted()
        guard !days.isEmpty else { return (0, 0) }
        var best = 0
        var current = 0
        var previousDay: Date?
        for day in days {
            if let previous = previousDay, let diff = calendar.dateComponents([.day], from: previous, to: day).day, diff == 1 {
                current += 1
            } else if previousDay == nil {
                current = 1
            } else {
                current = 1
            }
            best = max(best, current)
            previousDay = day
        }

        let today = calendar.startOfDay(for: Date())
        if let last = days.last, let diff = calendar.dateComponents([.day], from: last, to: today).day, diff > 1 {
            current = 0
        }
        return (current, best)
    }
}

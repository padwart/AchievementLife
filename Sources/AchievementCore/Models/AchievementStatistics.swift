import Foundation

public struct AchievementStatistics: Codable, Equatable, Sendable {
    public var totalAchievements: Int
    public var completedAchievements: Int
    public var completionRate: Double
    public var totalPointsEarned: Int
    public var currentStreak: Int
    public var bestStreak: Int
    public var completionsByWeekday: [Weekday: Int]
    public var completionHistory: [Date: Int]
    public var categoryBreakdown: [String: Int]

    public init(
        totalAchievements: Int,
        completedAchievements: Int,
        completionRate: Double,
        totalPointsEarned: Int,
        currentStreak: Int,
        bestStreak: Int,
        completionsByWeekday: [Weekday: Int],
        completionHistory: [Date: Int],
        categoryBreakdown: [String: Int]
    ) {
        self.totalAchievements = totalAchievements
        self.completedAchievements = completedAchievements
        self.completionRate = completionRate
        self.totalPointsEarned = totalPointsEarned
        self.currentStreak = currentStreak
        self.bestStreak = bestStreak
        self.completionsByWeekday = completionsByWeekday
        self.completionHistory = completionHistory
        self.categoryBreakdown = categoryBreakdown
    }
}

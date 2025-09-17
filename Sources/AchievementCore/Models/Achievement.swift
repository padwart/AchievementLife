import Foundation

public struct Achievement: Codable, Identifiable, Equatable, Sendable {
    public var id: UUID
    public var title: String
    public var detail: String
    public var icon: IconReference
    public var points: Int
    public var category: String
    public var schedule: AchievementSchedule
    public var reminderTimes: [DateComponents]
    public var createdAt: Date
    public var isArchived: Bool

    public init(
        id: UUID = UUID(),
        title: String,
        detail: String,
        icon: IconReference,
        points: Int = 10,
        category: String = "General",
        schedule: AchievementSchedule,
        reminderTimes: [DateComponents] = [],
        createdAt: Date = Date(),
        isArchived: Bool = false
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.icon = icon
        self.points = points
        self.category = category
        self.schedule = schedule
        self.reminderTimes = reminderTimes
        self.createdAt = createdAt
        self.isArchived = isArchived
    }
}

public struct AchievementCompletion: Codable, Identifiable, Equatable, Sendable {
    public var id: UUID
    public var achievementID: Achievement.ID
    public var completedAt: Date
    public var pointsEarned: Int

    public init(id: UUID = UUID(), achievementID: Achievement.ID, completedAt: Date, pointsEarned: Int) {
        self.id = id
        self.achievementID = achievementID
        self.completedAt = completedAt
        self.pointsEarned = pointsEarned
    }
}

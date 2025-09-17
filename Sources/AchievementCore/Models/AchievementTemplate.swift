import Foundation

public struct AchievementTemplate: Codable, Equatable, Sendable, Identifiable {
    public var id: UUID
    public var title: String
    public var detail: String
    public var icon: IconReference
    public var points: Int
    public var category: String
    public var schedule: AchievementSchedule

    public init(
        id: UUID = UUID(),
        title: String,
        detail: String,
        icon: IconReference,
        points: Int,
        category: String,
        schedule: AchievementSchedule
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.icon = icon
        self.points = points
        self.category = category
        self.schedule = schedule
    }
}

public extension Array where Element == AchievementTemplate {
    static var everydayWellness: [AchievementTemplate] {
        [
            AchievementTemplate(
                title: "Make Your Bed",
                detail: "Start the day with a quick win by making your bed.",
                icon: .system("bed.double.fill"),
                points: 5,
                category: "Morning",
                schedule: .daily
            ),
            AchievementTemplate(
                title: "Tidy the Kitchen",
                detail: "Do the dishes or wipe down the counters after meals.",
                icon: .system("fork.knife"),
                points: 10,
                category: "Home",
                schedule: .daily
            ),
            AchievementTemplate(
                title: "Workout Session",
                detail: "Complete a workout or head to the gym.",
                icon: .system("dumbbell.fill"),
                points: 20,
                category: "Fitness",
                schedule: .weekly([.monday, .wednesday, .friday])
            ),
            AchievementTemplate(
                title: "Study Block",
                detail: "Focus on studying or learning for at least 45 minutes.",
                icon: .system("book.fill"),
                points: 15,
                category: "Learning",
                schedule: .weekly([.monday, .tuesday, .wednesday, .thursday])
            ),
            AchievementTemplate(
                title: "Laundry Day",
                detail: "Stay on top of laundry so it never piles up.",
                icon: .system("laundry"),
                points: 15,
                category: "Home",
                schedule: .weekly([.saturday])
            )
        ]
    }
}

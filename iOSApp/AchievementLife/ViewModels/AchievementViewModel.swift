import Foundation
import SwiftUI
import UserNotifications
import AchievementCore

@MainActor
final class AchievementViewModel: ObservableObject {
    @Published private(set) var state: AchievementState
    @Published var selectedDate: Date
    @Published var notificationsEnabled: Bool

    private let persistence: AchievementPersistence
    private let notificationScheduler = NotificationScheduler()
    private(set) var templates: [AchievementTemplate] = .everydayWellness

    let calendar: Calendar

    init(
        state: AchievementState = AchievementState(),
        persistence: AchievementPersistence? = nil,
        calendar: Calendar = .current,
        preview: Bool = false
    ) {
        self.calendar = calendar
        self.persistence = persistence ?? AchievementPersistence()
        if preview {
            self.state = AchievementState(achievements: Self.previewAchievements, completions: [])
        } else if let loaded = try? self.persistence.load() {
            self.state = loaded
        } else {
            self.state = state
        }
        self.selectedDate = calendar.startOfDay(for: Date())
        self.notificationsEnabled = false
    }

    var achievementsDueToday: [Achievement] {
        state.achievementsDue(on: selectedDate, calendar: calendar)
    }

    var todaysCompletionCount: Int {
        state.completions.filter { calendar.isDate($0.completedAt, inSameDayAs: selectedDate) }.count
    }

    var completionStats: AchievementStatistics {
        let start = calendar.startOfDay(for: selectedDate)
        let historicalStart = calendar.date(byAdding: .day, value: -30, to: start) ?? start
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start
        let interval = DateInterval(start: historicalStart, end: end)
        return state.statistics(for: interval, calendar: calendar)
    }

    func isCompleted(_ achievement: Achievement) -> Bool {
        state.isCompleted(achievement.id, on: selectedDate, calendar: calendar)
    }

    func toggleCompletion(_ achievement: Achievement) {
        state.toggleCompletion(for: achievement.id, on: selectedDate, calendar: calendar)
        persistState()
    }

    func addAchievement(_ achievement: Achievement) {
        state.addAchievement(achievement)
        persistState()
        scheduleNotifications(for: achievement)
    }

    func updateAchievement(_ achievement: Achievement) {
        state.updateAchievement(achievement)
        persistState()
        scheduleNotifications(for: achievement)
    }

    func removeAchievements(at offsets: IndexSet) {
        offsets.map { state.achievements[$0] }.forEach { achievement in
            state.removeAchievement(id: achievement.id)
        }
        persistState()
    }

    func nextOccurrences(for achievement: Achievement, limit: Int = 5) -> [Date] {
        state.upcomingOccurrences(for: achievement.id, from: selectedDate, limit: limit, calendar: calendar)
    }

    func saveFromTemplate(_ template: AchievementTemplate) {
        let achievement = Achievement(
            title: template.title,
            detail: template.detail,
            icon: template.icon,
            points: template.points,
            category: template.category,
            schedule: template.schedule
        )
        addAchievement(achievement)
    }

    func reloadState() {
        if let loaded = try? persistence.load() {
            state = loaded
        }
    }

    func requestNotificationPermissions() async {
        notificationsEnabled = await notificationScheduler.requestAuthorization()
        if notificationsEnabled {
            for achievement in state.achievements {
                scheduleNotifications(for: achievement)
            }
        }
    }

    func scheduleNotifications(for achievement: Achievement) {
        guard notificationsEnabled else { return }
        notificationScheduler.scheduleNotifications(for: achievement, calendar: calendar)
    }

    func refreshReminders() {
        notificationScheduler.clearScheduledNotifications()
        if notificationsEnabled {
            for achievement in state.achievements {
                scheduleNotifications(for: achievement)
            }
        }
    }

    private func persistState() {
        try? persistence.save(state)
    }
}

private extension AchievementViewModel {
    static var previewAchievements: [Achievement] {
        [
            Achievement(
                title: "Make the Bed",
                detail: "Smooth the sheets and fluff the pillows.",
                icon: .system("bed.double.fill"),
                points: 5,
                category: "Home",
                schedule: .daily
            ),
            Achievement(
                title: "Gym Session",
                detail: "Complete a 45-minute workout.",
                icon: .system("dumbbell.fill"),
                points: 20,
                category: "Fitness",
                schedule: .weekly([.monday, .wednesday, .friday])
            )
        ]
    }
}

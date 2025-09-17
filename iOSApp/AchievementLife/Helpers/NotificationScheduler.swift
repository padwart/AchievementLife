import Foundation
import UserNotifications
import AchievementCore

struct NotificationScheduler {
    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        if settings.authorizationStatus == .notDetermined {
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
                return granted
            } catch {
                return false
            }
        }
        return settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
    }

    func scheduleNotifications(for achievement: Achievement, calendar: Calendar) {
        guard !achievement.reminderTimes.isEmpty else { return }
        let center = UNUserNotificationCenter.current()
        for components in achievement.reminderTimes {
            let content = UNMutableNotificationContent()
            content.title = achievement.title
            content.body = achievement.detail
            content.sound = .default

            var triggerComponents = components
            triggerComponents.calendar = calendar
            if triggerComponents.timeZone == nil {
                triggerComponents.timeZone = calendar.timeZone
            }

            let identifier = notificationIdentifier(for: achievement.id, components: components)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: true)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            center.add(request)
        }
    }

    func clearScheduledNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    private func notificationIdentifier(for id: UUID, components: DateComponents) -> String {
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        return "achievement_\(id.uuidString)_\(hour)_\(minute)"
    }
}

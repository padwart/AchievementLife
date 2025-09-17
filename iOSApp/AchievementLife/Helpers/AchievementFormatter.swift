import Foundation
import SwiftUI

struct AchievementFormatter {
    let calendar: Calendar

    func format(date: Date, style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateStyle = style
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    func formatTime(from components: DateComponents) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        if let date = calendar.date(from: components) {
            return formatter.string(from: date)
        }
        return "Time"
    }
}

private struct AchievementFormatterKey: EnvironmentKey {
    static let defaultValue = AchievementFormatter(calendar: Calendar(identifier: .gregorian))
}

extension EnvironmentValues {
    var achievementFormatter: AchievementFormatter {
        get { self[AchievementFormatterKey.self] }
        set { self[AchievementFormatterKey.self] = newValue }
    }
}

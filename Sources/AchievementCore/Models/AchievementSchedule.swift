import Foundation

public enum AchievementSchedule: Codable, Equatable, Sendable {
    case daily
    case weekly(Set<Weekday>)
    case monthly(Set<Int>)
    case specificDates([DateComponents])
    case customInterval(days: Int, anchorDate: Date)

    enum CodingKeys: String, CodingKey {
        case type
        case weekdays
        case monthDays
        case dates
        case interval
        case anchor
    }

    private enum ScheduleType: String, Codable {
        case daily
        case weekly
        case monthly
        case specificDates
        case customInterval
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ScheduleType.self, forKey: .type)
        switch type {
        case .daily:
            self = .daily
        case .weekly:
            let weekdays = try container.decode(Set<Weekday>.self, forKey: .weekdays)
            self = .weekly(weekdays)
        case .monthly:
            let days = try container.decode(Set<Int>.self, forKey: .monthDays)
            self = .monthly(days)
        case .specificDates:
            let dates = try container.decode([DateComponents].self, forKey: .dates)
            self = .specificDates(dates)
        case .customInterval:
            let days = try container.decode(Int.self, forKey: .interval)
            let anchor = try container.decode(Date.self, forKey: .anchor)
            self = .customInterval(days: days, anchorDate: anchor)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .daily:
            try container.encode(ScheduleType.daily, forKey: .type)
        case .weekly(let weekdays):
            try container.encode(ScheduleType.weekly, forKey: .type)
            try container.encode(weekdays, forKey: .weekdays)
        case .monthly(let days):
            try container.encode(ScheduleType.monthly, forKey: .type)
            try container.encode(days, forKey: .monthDays)
        case .specificDates(let dates):
            try container.encode(ScheduleType.specificDates, forKey: .type)
            try container.encode(dates, forKey: .dates)
        case .customInterval(let days, let anchor):
            try container.encode(ScheduleType.customInterval, forKey: .type)
            try container.encode(days, forKey: .interval)
            try container.encode(anchor, forKey: .anchor)
        }
    }

    public func isDue(on date: Date, calendar: Calendar) -> Bool {
        switch self {
        case .daily:
            return true
        case .weekly(let weekdays):
            let weekday = Weekday(rawValue: calendar.component(.weekday, from: date)) ?? .monday
            return weekdays.contains(weekday)
        case .monthly(let days):
            let day = calendar.component(.day, from: date)
            return days.contains(day)
        case .specificDates(let components):
            let comps = calendar.dateComponents([.year, .month, .day], from: date)
            return components.contains(where: { matches($0, comps, calendar: calendar) })
        case .customInterval(let interval, let anchorDate):
            let start = calendar.startOfDay(for: anchorDate)
            let target = calendar.startOfDay(for: date)
            guard target >= start else { return false }
            let diff = calendar.dateComponents([.day], from: start, to: target).day ?? 0
            return diff % interval == 0
        }
    }

    public func nextOccurrences(from startDate: Date, limit: Int, calendar: Calendar) -> [Date] {
        guard limit > 0 else { return [] }
        switch self {
        case .daily:
            return stride(from: 0, to: limit, by: 1).compactMap { offset in
                calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: startDate))
            }
        case .weekly(let weekdays):
            return nextWeeklyOccurrences(weekdays: weekdays, startDate: startDate, limit: limit, calendar: calendar)
        case .monthly(let days):
            return nextMonthlyOccurrences(days: days, startDate: startDate, limit: limit, calendar: calendar)
        case .specificDates(let dates):
            let sorted = dates.compactMap { calendar.date(from: $0) }.sorted()
            return sorted.filter { $0 >= calendar.startOfDay(for: startDate) }.prefix(limit).map { $0 }
        case .customInterval(let days, let anchorDate):
            let anchor = calendar.startOfDay(for: anchorDate)
            var results: [Date] = []
            var current = anchor
            while results.count < limit {
                if current >= calendar.startOfDay(for: startDate) {
                    results.append(current)
                }
                guard let next = calendar.date(byAdding: .day, value: days, to: current) else { break }
                current = next
            }
            return results
        }
    }

    private func matches(_ lhs: DateComponents, _ rhs: DateComponents, calendar: Calendar) -> Bool {
        let yearMatch = lhs.year == nil || lhs.year == rhs.year
        let monthMatch = lhs.month == nil || lhs.month == rhs.month
        let dayMatch = lhs.day == nil || lhs.day == rhs.day
        return yearMatch && monthMatch && dayMatch
    }

    private func nextWeeklyOccurrences(weekdays: Set<Weekday>, startDate: Date, limit: Int, calendar: Calendar) -> [Date] {
        guard !weekdays.isEmpty else { return [] }
        var results: [Date] = []
        var current = calendar.startOfDay(for: startDate)
        while results.count < limit {
            let weekday = Weekday(rawValue: calendar.component(.weekday, from: current)) ?? .monday
            if weekdays.contains(weekday) {
                results.append(current)
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return results
    }

    private func nextMonthlyOccurrences(days: Set<Int>, startDate: Date, limit: Int, calendar: Calendar) -> [Date] {
        let validDays = days.filter { $0 >= 1 && $0 <= 31 }.sorted()
        guard !validDays.isEmpty else { return [] }
        var results: [Date] = []
        var monthCursor = calendar.startOfDay(for: startDate)
        let startOfDay = calendar.startOfDay(for: startDate)
        while results.count < limit {
            for day in validDays {
                var components = calendar.dateComponents([.year, .month], from: monthCursor)
                components.day = day
                guard let date = calendar.date(from: components) else { continue }
                if date >= startOfDay {
                    results.append(date)
                    if results.count == limit { break }
                }
            }
            guard let nextMonth = calendar.date(byAdding: DateComponents(month: 1), to: monthCursor) else { break }
            monthCursor = nextMonth
        }
        return results
    }
}

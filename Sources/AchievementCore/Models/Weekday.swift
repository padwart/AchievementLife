import Foundation

public enum Weekday: Int, CaseIterable, Codable, Sendable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday

    public var localizedName: String {
        let symbols = Calendar.current.weekdaySymbols
        return symbols[(rawValue - 1) % symbols.count]
    }

    public func advanced(by offset: Int) -> Weekday {
        let all = Weekday.allCases
        let index = (rawValue - 1 + offset) % all.count
        return all[(index + all.count) % all.count]
    }
}

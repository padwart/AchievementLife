import SwiftUI
import AchievementCore

struct ScheduleEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var schedule: AchievementSchedule
    @State private var selectedFrequency: Frequency = .daily
    @State private var selectedWeekdays: Set<Weekday> = []
    @State private var monthlyDays: Set<Int> = []
    @State private var specificDates: [Date] = []
    @State private var intervalDays: Int = 2
    @State private var anchorDate: Date = Date()

    enum Frequency: String, CaseIterable, Identifiable {
        case daily
        case weekly
        case monthly
        case specificDates
        case customInterval

        var id: String { rawValue }

        var title: String {
            switch self {
            case .daily: return "Daily"
            case .weekly: return "Weekly"
            case .monthly: return "Monthly"
            case .specificDates: return "Specific Dates"
            case .customInterval: return "Interval"
            }
        }
    }

    init(schedule: Binding<AchievementSchedule>) {
        self._schedule = schedule
        switch schedule.wrappedValue {
        case .daily:
            _selectedFrequency = State(initialValue: .daily)
        case .weekly(let days):
            _selectedFrequency = State(initialValue: .weekly)
            _selectedWeekdays = State(initialValue: days)
        case .monthly(let days):
            _selectedFrequency = State(initialValue: .monthly)
            _monthlyDays = State(initialValue: days)
        case .specificDates(let dates):
            _selectedFrequency = State(initialValue: .specificDates)
            let calendar = Calendar.current
            let resolved = dates.compactMap { calendar.date(from: $0) }
            _specificDates = State(initialValue: resolved)
        case .customInterval(let days, let anchor):
            _selectedFrequency = State(initialValue: .customInterval)
            _intervalDays = State(initialValue: days)
            _anchorDate = State(initialValue: anchor)
        }
    }

    var body: some View {
        Form {
            Picker("Frequency", selection: $selectedFrequency) {
                ForEach(Frequency.allCases) { frequency in
                    Text(frequency.title).tag(frequency)
                }
            }
            .pickerStyle(.segmented)

            switch selectedFrequency {
            case .daily:
                EmptyView()
            case .weekly:
                weekdaySelector
            case .monthly:
                monthlySelector
            case .specificDates:
                specificDateSelector
            case .customInterval:
                intervalSelector
            }
        }
        .navigationTitle("Schedule")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    commitChanges()
                    dismiss()
                }
            }
        }
        .onChange(of: selectedFrequency) { _ in
            commitChanges()
        }
    }

    private var weekdaySelector: some View {
        VStack(alignment: .leading) {
            Text("Select days")
                .font(.headline)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                ForEach(Weekday.allCases, id: \.self) { weekday in
                    Button {
                        if selectedWeekdays.contains(weekday) {
                            selectedWeekdays.remove(weekday)
                        } else {
                            selectedWeekdays.insert(weekday)
                        }
                        commitChanges()
                    } label: {
                        Text(weekday.localizedName.prefix(3))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(selectedWeekdays.contains(weekday) ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var monthlySelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Days in the month")
                .font(.headline)
            MonthDayGrid(days: Array(1...31), selections: $monthlyDays)
                .onChange(of: monthlyDays) { _ in commitChanges() }
        }
    }

    private var specificDateSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add calendar dates")
                .font(.headline)
            ForEach(specificDates.indices, id: \.self) { index in
                HStack {
                    DatePicker("Date #\(index + 1)", selection: Binding(
                        get: { specificDates[index] },
                        set: { specificDates[index] = $0 }
                    ), displayedComponents: .date)
                    Button {
                        specificDates.remove(at: index)
                        commitChanges()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                }
            }

            Button {
                specificDates.append(Date())
                commitChanges()
            } label: {
                Label("Add Date", systemImage: "calendar.badge.plus")
            }
        }
    }

    private var intervalSelector: some View {
        VStack(alignment: .leading, spacing: 16) {
            Stepper(value: $intervalDays, in: 2...30) {
                Text("Every \(intervalDays) days")
            }
            DatePicker("Anchor Date", selection: $anchorDate, displayedComponents: .date)
        }
        .onChange(of: intervalDays) { _ in commitChanges() }
        .onChange(of: anchorDate) { _ in commitChanges() }
    }

    private func commitChanges() {
        switch selectedFrequency {
        case .daily:
            schedule = .daily
        case .weekly:
            schedule = .weekly(selectedWeekdays)
        case .monthly:
            schedule = .monthly(monthlyDays)
        case .specificDates:
            let components = specificDates.map { Calendar.current.dateComponents([.year, .month, .day], from: $0) }
            schedule = .specificDates(components)
        case .customInterval:
            schedule = .customInterval(days: intervalDays, anchorDate: anchorDate)
        }
    }
}

private struct MonthDayGrid: View {
    let days: [Int]
    @Binding var selections: Set<Int>

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
            ForEach(days, id: \.self) { day in
                let isSelected = selections.contains(day)
                Button {
                    if isSelected {
                        selections.remove(day)
                    } else {
                        selections.insert(day)
                    }
                } label: {
                    Text("\(day)")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(isSelected ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

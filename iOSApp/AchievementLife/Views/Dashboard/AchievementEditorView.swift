import SwiftUI
import AchievementCore

struct AchievementEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var detail: String = ""
    @State private var points: Int = 10
    @State private var category: String = "General"
    @State private var schedule: AchievementSchedule = .daily
    @State private var icon: IconReference = .system("sparkles")
    @State private var reminderTimes: [DateComponents] = []
    @State private var showingIconPicker = false
    @State private var showingScheduleEditor = false

    var onSave: (Achievement) -> Void

    var body: some View {
        Form {
            Section("Basics") {
                TextField("Title", text: $title)
                TextField("Description", text: $detail, axis: .vertical)
                Stepper(value: $points, in: 5...100, step: 5) {
                    HStack {
                        Label("Points", systemImage: "star.fill")
                        Spacer()
                        Text("\(points)")
                            .monospacedDigit()
                    }
                }
                TextField("Category", text: $category)
            }

            Section("Schedule") {
                Button {
                    showingScheduleEditor = true
                } label: {
                    HStack {
                        Label("Frequency", systemImage: "calendar")
                        Spacer()
                        Text(scheduleDescription)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Icon & Reminders") {
                Button {
                    showingIconPicker = true
                } label: {
                    HStack {
                        Label("Icon", systemImage: "paintpalette")
                        Spacer()
                        AchievementIconView(icon: icon, isCompleted: false)
                    }
                }

                ForEach(reminderTimes.indices, id: \.self) { index in
                    DatePicker(
                        "Reminder #\(index + 1)",
                        selection: Binding(
                            get: { reminderDate(from: reminderTimes[index]) },
                            set: { reminderTimes[index] = calendarComponents(from: $0) }
                        ),
                        displayedComponents: [.hourAndMinute]
                    )
                }
                .onDelete { offsets in
                    reminderTimes.remove(atOffsets: offsets)
                }

                Button {
                    reminderTimes.append(calendarComponents(from: Date()))
                } label: {
                    Label("Add Reminder", systemImage: "bell.badge")
                }
            }
        }
        .navigationTitle("New Achievement")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    let achievement = Achievement(
                        title: title,
                        detail: detail,
                        icon: icon,
                        points: points,
                        category: category,
                        schedule: schedule,
                        reminderTimes: reminderTimes
                    )
                    onSave(achievement)
                    dismiss()
                }
                .disabled(title.isEmpty)
            }
        }
        .sheet(isPresented: $showingIconPicker) {
            IconPickerView(selectedIcon: $icon)
        }
        .sheet(isPresented: $showingScheduleEditor) {
            NavigationStack {
                ScheduleEditorView(schedule: $schedule)
            }
        }
    }

    private var scheduleDescription: String {
        switch schedule {
        case .daily:
            return "Daily"
        case .weekly(let days):
            let names = days.sorted { $0.rawValue < $1.rawValue }.map { $0.localizedName }
            return names.joined(separator: ", ")
        case .monthly(let days):
            let sorted = days.sorted()
            return sorted.map { "Day \($0)" }.joined(separator: ", ")
        case .specificDates(let dates):
            let formatter = DateFormatter()
            formatter.calendar = Calendar.current
            formatter.dateStyle = .medium
            let calendar = Calendar.current
            return dates.compactMap { calendar.date(from: $0) }.map { formatter.string(from: $0) }.joined(separator: ", ")
        case .customInterval(let days, _):
            return "Every \(days) days"
        }
    }

    private func reminderDate(from components: DateComponents) -> Date {
        let calendar = Calendar.current
        return calendar.date(from: components) ?? Date()
    }

    private func calendarComponents(from date: Date) -> DateComponents {
        var components = Calendar.current.dateComponents([.hour, .minute], from: date)
        components.calendar = Calendar.current
        return components
    }
}

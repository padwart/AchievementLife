import SwiftUI
import AchievementCore

struct SettingsView: View {
    @EnvironmentObject private var viewModel: AchievementViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Notifications") {
                    Toggle(isOn: $viewModel.notificationsEnabled) {
                        Label("Enable reminders", systemImage: "bell")
                    }
                    .onChange(of: viewModel.notificationsEnabled) { newValue in
                        if newValue {
                            Task { await viewModel.requestNotificationPermissions() }
                        } else {
                            viewModel.refreshReminders()
                        }
                    }
                    Button("Reschedule reminders") {
                        viewModel.refreshReminders()
                    }
                }

                Section("Data") {
                    Button("Reload from storage") {
                        viewModel.reloadState()
                    }
                    Button("Export achievements") {
                        exportAchievements()
                    }
                }

                Section("Roadmap") {
                    Label("Leaderboards and skins support can plug into your earned points with Game Center or custom APIs.", systemImage: "gamecontroller")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func exportAchievements() {
        guard let data = try? JSONEncoder().encode(viewModel.state) else { return }
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("AchievementLifeExport.json")
        try? data.write(to: tempURL)
        // ShareSheet integration would go here in a full app implementation
    }
}

#Preview {
    SettingsView()
        .environmentObject(AchievementViewModel(preview: true))
}

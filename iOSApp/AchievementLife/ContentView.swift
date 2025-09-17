import SwiftUI
import AchievementCore

struct ContentView: View {
    @EnvironmentObject private var viewModel: AchievementViewModel

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "checkmark.circle")
                }

            StatsOverviewView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.xaxis")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .environment(
            \._achievementFormatter,
            AchievementFormatter(calendar: viewModel.calendar)
        )
    }
}

#Preview {
    ContentView()
        .environmentObject(AchievementViewModel(preview: true))
}

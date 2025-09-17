import SwiftUI
import AchievementCore

@main
struct AchievementLifeApp: App {
    @StateObject private var viewModel = AchievementViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .task {
                    await viewModel.requestNotificationPermissions()
                }
        }
    }
}

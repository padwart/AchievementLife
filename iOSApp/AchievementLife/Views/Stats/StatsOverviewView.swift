import SwiftUI
import AchievementCore

struct StatsOverviewView: View {
    @EnvironmentObject private var viewModel: AchievementViewModel
    @Environment(\.achievementFormatter) private var formatter

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                streakCard
                pointsCard
                weekdayBreakdown
                upcomingList
            }
            .padding()
        }
        .navigationTitle("Stats")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Performance Snapshot")
                .font(.largeTitle.bold())
            Text("Track your momentum and see how consistent you have been.")
                .foregroundStyle(.secondary)
        }
    }

    private var streakCard: some View {
        let stats = viewModel.completionStats
        return VStack(alignment: .leading, spacing: 12) {
            Label("Current Streak", systemImage: "flame.fill")
                .font(.headline)
                .foregroundStyle(.orange)
            Text("\(stats.currentStreak) days")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(.orange)
            Text("Best streak \(stats.bestStreak) days")
                .foregroundStyle(.secondary)
            ProgressView(value: Double(stats.currentStreak), total: Double(max(stats.bestStreak, 1)))
                .tint(.orange)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var pointsCard: some View {
        let stats = viewModel.completionStats
        return VStack(alignment: .leading, spacing: 12) {
            Label("Achievement Points", systemImage: "star.fill")
                .font(.headline)
            Text("\(stats.totalPointsEarned) pts")
                .font(.system(size: 40, weight: .semibold, design: .rounded))
            Text("Completion rate \(Int(stats.completionRate * 100))%")
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.yellow.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var weekdayBreakdown: some View {
        let stats = viewModel.completionStats
        return VStack(alignment: .leading, spacing: 12) {
            Label("Weekday Momentum", systemImage: "calendar")
                .font(.headline)
            ForEach(Weekday.allCases, id: \.self) { weekday in
                let count = stats.completionsByWeekday[weekday, default: 0]
                HStack {
                    Text(weekday.localizedName)
                    Spacer()
                    Text("\(count)")
                        .monospacedDigit()
                }
                .padding(.vertical, 8)
                .padding(.horizontal)
                .background(Color.gray.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var upcomingList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Upcoming Achievements", systemImage: "clock")
                .font(.headline)
            ForEach(viewModel.state.achievements) { achievement in
                let occurrences = viewModel.nextOccurrences(for: achievement, limit: 3)
                if !occurrences.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(achievement.title)
                            .font(.headline)
                        ForEach(occurrences, id: \.self) { occurrence in
                            Text(formatter.format(date: occurrence))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }
}

#Preview {
    StatsOverviewView()
        .environmentObject(AchievementViewModel(preview: true))
}

import SwiftUI
import AchievementCore

struct DashboardView: View {
    @EnvironmentObject private var viewModel: AchievementViewModel
    @State private var showingAddSheet = false
    @State private var showingTemplates = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                header
                progressSummary
                if viewModel.achievementsDueToday.isEmpty {
                    EmptyDashboardState(showingAddSheet: $showingAddSheet, showingTemplates: $showingTemplates)
                } else {
                    List {
                        Section("Today's Achievements") {
                            ForEach(viewModel.achievementsDueToday) { achievement in
                                AchievementRowView(
                                    achievement: achievement,
                                    isCompleted: viewModel.isCompleted(achievement)
                                ) {
                                    viewModel.toggleCompletion(achievement)
                                }
                                .contentShape(Rectangle())
                                .contextMenu {
                                    Button("View Details") {
                                        showingDetail(for: achievement)
                                    }
                                    Button("Skip Today", role: .destructive) {
                                        viewModel.toggleCompletion(achievement)
                                    }
                                }
                            }
                            .onDelete(perform: viewModel.removeAchievements)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Achievement Life")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        showingTemplates = true
                    } label: {
                        Label("Templates", systemImage: "sparkles")
                    }
                    Button {
                        showingAddSheet = true
                    } label: {
                        Label("Add Achievement", systemImage: "plus")
                    }
                    .accessibilityIdentifier("addAchievementButton")
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                NavigationStack {
                    AchievementEditorView { newAchievement in
                        viewModel.addAchievement(newAchievement)
                    }
                }
            }
            .sheet(isPresented: $showingTemplates) {
                TemplateGalleryView(templates: viewModel.templates) { template in
                    viewModel.saveFromTemplate(template)
                }
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Today")
                    .font(.title2).bold()
                Text(Date.now, style: .date)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Menu {
                DatePicker("Jump to Date", selection: $viewModel.selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
            } label: {
                Label("Select Date", systemImage: "calendar")
            }
        }
    }

    private var progressSummary: some View {
        let stats = viewModel.completionStats
        let totalToday = max(1, viewModel.achievementsDueToday.count)
        let completed = viewModel.todaysCompletionCount

        return VStack(alignment: .leading, spacing: 12) {
            ProgressView(value: Double(completed), total: Double(totalToday)) {
                Text("Daily Progress")
                    .font(.headline)
            } currentValueLabel: {
                Text("\(completed)/\(totalToday)")
                    .monospacedDigit()
            }
            .tint(.green)

            HStack {
                StatPill(title: "Streak", value: "\(stats.currentStreak) 🔥")
                StatPill(title: "Best", value: "\(stats.bestStreak)")
                StatPill(title: "Points", value: "\(stats.totalPointsEarned)")
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func showingDetail(for achievement: Achievement) {
        // Placeholder for navigation hooks if detail view is added later
    }
}

private struct StatPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.accentColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct EmptyDashboardState: View {
    @Binding var showingAddSheet: Bool
    @Binding var showingTemplates: Bool

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "wand.and.stars")
                .font(.largeTitle)
                .padding(12)
            Text("No achievements yet")
                .font(.headline)
            Text("Create custom achievements or explore curated templates to start earning points.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            HStack {
                Button("Browse Templates") {
                    showingTemplates = true
                }
                Button("Create Achievement") {
                    showingAddSheet = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(style: .init(lineWidth: 1, dash: [4]))
                .foregroundStyle(.secondary)
        )
    }
}

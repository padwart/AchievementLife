import SwiftUI
import AchievementCore

struct AchievementRowView: View {
    let achievement: Achievement
    let isCompleted: Bool
    var onToggle: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            AchievementIconView(icon: achievement.icon, isCompleted: isCompleted)
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                Text(achievement.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack {
                    Label("\(achievement.points) pts", systemImage: "star.fill")
                        .labelStyle(.iconOnly)
                        .foregroundStyle(.yellow)
                    Text("\(achievement.points) pts")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(achievement.category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.12))
                        .clipShape(Capsule())
                }
            }
            Spacer()
            Button(action: onToggle) {
                Image(systemName: isCompleted ? "checkmark.seal.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isCompleted ? Color.green : Color.secondary)
                    .symbolEffect(.bounce, value: isCompleted)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
    }
}

struct AchievementIconView: View {
    let icon: IconReference
    let isCompleted: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(isCompleted ? Color.green.opacity(0.2) : Color.accentColor.opacity(0.12))
                .frame(width: 48, height: 48)
            switch icon.source {
            case .systemSymbol:
                Image(systemName: icon.value)
                    .font(.title2)
                    .foregroundStyle(isCompleted ? Color.green : Color.accentColor)
            case .remoteURL:
                RemoteAchievementIcon(url: icon.remoteURL)
            }
        }
    }
}

private struct RemoteAchievementIcon: View {
    let url: URL?

    var body: some View {
        if let url {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure:
                    fallbackIcon
                @unknown default:
                    fallbackIcon
                }
            }
            .frame(width: 32, height: 32)
        } else {
            fallbackIcon
        }
    }

    private var fallbackIcon: some View {
        Image(systemName: "app.fill")
            .font(.title2)
            .foregroundStyle(.secondary)
    }
}

#Preview {
    AchievementRowView(
        achievement: Achievement(
            title: "Daily Stretch",
            detail: "Spend 10 minutes stretching",
            icon: .system("figure.cooldown"),
            points: 10,
            category: "Wellness",
            schedule: .daily
        ),
        isCompleted: true,
        onToggle: {}
    )
    .padding()
    .previewLayout(.sizeThatFits)
}

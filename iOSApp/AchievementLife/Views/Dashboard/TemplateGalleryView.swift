import SwiftUI
import AchievementCore

struct TemplateGalleryView: View {
    @Environment(\.dismiss) private var dismiss
    let templates: [AchievementTemplate]
    var onSelect: (AchievementTemplate) -> Void

    var body: some View {
        NavigationStack {
            List {
                ForEach(templates) { template in
                    Button {
                        onSelect(template)
                        dismiss()
                    } label: {
                        HStack(spacing: 16) {
                            AchievementIconView(icon: template.icon, isCompleted: false)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(template.title)
                                    .font(.headline)
                                Text(template.detail)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Templates")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

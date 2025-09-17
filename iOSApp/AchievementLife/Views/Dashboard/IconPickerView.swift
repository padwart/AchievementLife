import SwiftUI
import AchievementCore

struct IconPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedIcon: IconReference
    @State private var searchText: String = ""

    private let symbolCategories: [IconCategory] = IconCategory.defaultCategories

    var body: some View {
        NavigationStack {
            List {
                if !searchText.isEmpty {
                    Section("Search Results") {
                        symbolGrid(for: filteredSymbols)
                    }
                }

                ForEach(symbolCategories) { category in
                    Section(category.name) {
                        symbolGrid(for: category.symbols)
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Choose Icon")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var filteredSymbols: [String] {
        let query = searchText.lowercased()
        guard !query.isEmpty else { return [] }
        return IconCategory.allSymbols.filter { $0.contains(query) }
    }

    @ViewBuilder
    private func symbolGrid(for symbols: [String]) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.adaptive(minimum: 44), spacing: 12), count: 3), spacing: 12) {
            ForEach(symbols, id: \.self) { symbol in
                Button {
                    selectedIcon = .system(symbol)
                    dismiss()
                } label: {
                    VStack {
                        Image(systemName: symbol)
                            .font(.title2)
                            .frame(width: 44, height: 44)
                            .background(selectedIcon.value == symbol ? Color.accentColor.opacity(0.2) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        Text(symbol)
                            .font(.caption2)
                            .lineLimit(1)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
    }
}

private struct IconCategory: Identifiable {
    let id = UUID()
    let name: String
    let symbols: [String]

    static let defaultCategories: [IconCategory] = [
        IconCategory(name: "Habits", symbols: ["checkmark.circle", "sparkles", "target", "flag.checkered"]),
        IconCategory(name: "Home", symbols: ["bed.double.fill", "fork.knife", "house.fill", "sofa.fill", "laundry"]),
        IconCategory(name: "Health", symbols: ["heart.fill", "cross.case.fill", "bandage.fill", "pill" ]),
        IconCategory(name: "Fitness", symbols: ["figure.run", "dumbbell.fill", "bicycle", "sportscourt"]),
        IconCategory(name: "Learning", symbols: ["book.fill", "graduationcap.fill", "brain.head.profile", "pencil"]),
        IconCategory(name: "Lifestyle", symbols: ["music.note", "gamecontroller.fill", "paintbrush.pointed", "leaf.fill"])
    ]

    static var allSymbols: [String] {
        defaultCategories.flatMap(\.symbols)
    }
}

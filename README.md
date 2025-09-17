# Achievement Life

Achievement Life is a SwiftUI iPhone app concept that gamifies everyday habits. Track progress, collect statistics, and keep momentum through customizable achievements, local reminders, and iconography that fits your goals.

## Highlights

- **Daily dashboard** that shows all achievements due for the selected day, with quick completion toggles and progress indicators.
- **Flexible scheduling** that supports daily, weekly, monthly, custom-interval, or specific-date achievements.
- **Custom achievements** created through an editor that lets you configure points, categories, schedules, reminders, and iconography.
- **Statistics and insights** including streak tracking, completion rates, and upcoming schedule previews.
- **Local notifications** via `UNUserNotificationCenter`, with a scheduler that can be swapped out when integrating with push notification providers.
- **Template gallery** that ships with ready-made achievements for chores, studying, and fitness routines.
- **Icon picker** powered by SF Symbols, with the ability to extend toward stock photo APIs for richer imagery.
- **Extensibility hooks** to layer in Game Center leaderboards, cosmetics, or other reward systems based on earned points.

## Project Layout

```
AchievementLife/
├── Package.swift                  # Swift Package describing the shared logic module
├── README.md                      # Project overview
├── Sources/
│   └── AchievementCore/           # Platform-neutral models, persistence, and statistics helpers
├── Tests/
│   └── AchievementCoreTests/      # Unit tests that validate scheduling, persistence, and statistics
└── iOSApp/
    └── AchievementLife/           # SwiftUI application files ready for Xcode
```

The `AchievementCore` package contains all core models and state management. It can be imported by other platforms or reused in future targets (watchOS, macOS, or server sync services). The SwiftUI application under `iOSApp/` consumes the package and provides all user interface components.

## Getting Started

1. Open `iOSApp/AchievementLife/AchievementLifeApp.swift` in Xcode (15 or later recommended).
2. Create an Xcode project that references the `AchievementCore` Swift package located at the repository root.
3. Build and run on an iPhone simulator running iOS 17 or later.

### Notifications

The view model requests local notification permissions on launch. To test reminders:

1. Allow notification permission when prompted in the simulator or on device.
2. Add reminder times while creating or editing an achievement.
3. Use the Settings tab to reschedule reminders.

### Extending the Experience

- **Leaderboards / Skins:** Use the `AchievementStatistics` totals to sync with Game Center leaderboards or unlock cosmetic rewards after reaching certain point thresholds.
- **Cloud sync:** Swap `AchievementPersistence` with a cloud-backed store (CloudKit, Firebase) to keep progress in sync across devices.
- **Stock photo icons:** Replace `IconPickerView` with a picker backed by an API such as Unsplash or Pexels, and store the resulting URL in `IconReference.remoteURL`.

## Running Tests

The shared logic is validated with Swift Package Manager tests:

```bash
swift test
```

These tests cover schedule recurrence logic, statistics calculation, and persistence.

## License

This project is available under the MIT License. See [LICENSE](LICENSE) for details.

## 1. Setup & Dependencies

- [x] 1.1 Add `flutter_riverpod` dependency to `pubspec.yaml`
- [x] 1.2 Wrap the root app widget with `ProviderScope` in `main.dart`
- [x] 1.3 Ensure `SharedPreferences` is initialized before app run if synchronous loading is desired

## 2. Theme Definitions

- [x] 2.1 Define the "Deep Slate/Charcoal" color palette (e.g. background `#121212`, surface `#1E1E1E`, primary seed deep purple)
- [x] 2.2 Create `_lightThemeData` and `_darkThemeData` inside a central theme manager or core configuration file

## 3. State Management

- [x] 3.1 Create a `ThemeModeController` (Notifier or StateNotifier) using Riverpod
- [x] 3.2 Implement local persistence within `ThemeModeController` using `shared_preferences`
- [x] 3.3 Expose methods to change theme mode (`setThemeMode(ThemeMode mode)`)

## 4. UI Implementation

- [x] 4.1 Update `MaterialApp` to watch the `ThemeModeController` provider for its `themeMode` property
- [x] 4.2 Add `theme` and `darkTheme` properties to `MaterialApp`
- [x] 4.3 Create a UI settings toggle or segmented button to switch between Light, Dark, and System modes
- [x] 4.4 Verify all custom UI components respond correctly to the new `Theme.of(context)` values

## 5. Testing

- [x] 5.1 Write unit tests for `ThemeModeController` state transitions (Light/Dark/System)
- [x] 5.2 Write unit tests verifying `SharedPreferences` interaction for persistence
- [x] 5.3 Write widget tests for the new UI settings toggle to verify theme switching visually updates the tree

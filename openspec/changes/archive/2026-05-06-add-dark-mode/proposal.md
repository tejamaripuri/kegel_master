## Why

To enhance the user experience by providing a premium, calming visual interface that is easier on the eyes, especially in low-light environments. A dark mode aligns with Kegel Master's focus on wellness and provides an expected, high-quality feature for modern mobile applications.

## What Changes

- Add a tri-state theme mode preference (Light, Dark, System Default).
- Introduce a new "Deep Slate/Charcoal" color palette for the dark theme.
- Add Riverpod for state management of user theme preferences.
- Save user preference using SharedPreferences so the setting persists across app sessions.
- Update the UI to include a theme toggle/settings control.

## Capabilities

### New Capabilities
- `theme-management`: Tri-state dark mode preference and persistence.

### Modified Capabilities
- (None)

## Impact

- **Dependencies:** `flutter_riverpod` needs to be added to `pubspec.yaml`.
- **Architecture:** Introduction of Riverpod providers for theming state.
- **UI/UX:** A new settings toggle will be added to the app. Existing colors will need to be evaluated and updated to support both light and dark variations correctly using `ColorScheme`.

## Context

Currently, Kegel Master uses a simple `ThemeData` based on a deep purple seed color and `useMaterial3: true`. As a wellness and health app, a calming aesthetic is critical. Users have requested a dark mode to make the app more comfortable to use in low-light environments. 

We need to add a tri-state theme mode preference (Light, Dark, System) and persist it locally.

## Goals / Non-Goals

**Goals:**
- Provide a tri-state theme toggle (Light / Dark / System).
- Design and apply a "Deep Slate/Charcoal" dark theme palette that aligns with the app's calming, premium feel.
- Persist user theme preference across app launches.
- Establish a state management pattern for theming using Riverpod.

**Non-Goals:**
- Allowing users to create custom color themes.
- Cloud syncing of theme preferences (local persistence only).

## Decisions

- **State Management:** Introduce `flutter_riverpod`. It is the modern standard for Flutter state management, allowing clean extraction of theme logic. We will create a `ThemeModeController` Notifier.
- **Persistence:** Use `shared_preferences`. It is lightweight, synchronously accessible after initial load, and already present in the `pubspec.yaml` (though we might need to verify if we need `shared_preferences_riverpod` or just standard `shared_preferences`).
- **Color Strategy:** Define explicit `_lightThemeData` and `_darkThemeData` inside our theme core classes, utilizing `ColorScheme.fromSeed` with deep slate/charcoal colors for the dark variant.

## Risks / Trade-offs

- **Risk:** Flash of unstyled content or wrong theme on app launch. 
  **Mitigation:** Ensure `SharedPreferences` is awaited and initialized in `main()` before `runApp()` is called, or use an async Riverpod provider that shows a splash screen until the theme is loaded.
- **Risk:** Existing hardcoded colors in widgets might not adapt to dark mode.
  **Mitigation:** We will ensure all widgets use `Theme.of(context).colorScheme` or `Theme.of(context).textTheme` rather than hardcoded hex codes.

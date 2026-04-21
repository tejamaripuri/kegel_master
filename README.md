# Kegel Master

Flutter app for guided Kegel (pelvic floor) exercise sessions. (See `pubspec.yaml` description for the canonical one-liner.)

## Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) with a Dart SDK compatible with **`^3.10.8`** (see `environment` in [pubspec.yaml](pubspec.yaml)).

## Quick start

From the project root:

```bash
flutter pub get
flutter run
```

Use your IDE’s device selector or pass `-d <device_id>` to target a specific device.

Optional checks:

```bash
flutter analyze
flutter test
```

## Project layout

- [`lib/main.dart`](lib/main.dart) — `main()` entry; runs `KegelMasterApp`.
- [`lib/app.dart`](lib/app.dart) — root `MaterialApp` and theme.
- [`lib/features/`](lib/features/) — feature-first code; each area has a `presentation/` folder with screens.
- Bottom tabs: **Home**, **Learn**, **Progress**, **Settings** (wired in [`lib/features/shell/main_navigation_shell.dart`](lib/features/shell/main_navigation_shell.dart)).

## Further reading

- [Architecture overview](docs/ARCHITECTURE.md) — navigation, feature map, and conventions for extending the app.

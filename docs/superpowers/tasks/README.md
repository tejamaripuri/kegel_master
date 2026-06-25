# Local implementation tasks

Tracker-agnostic vertical slices derived from specs under `docs/superpowers/specs/`. Use dependency order when picking up work.

| Spec | Tasks file |
|------|----------------|
| Learn tab (2026-05-26) | [learn-tab-vertical-slices.md](./learn-tab-vertical-slices.md) |

## Learn tab — slice status

| Task | Name | Status | Notes |
|------|------|--------|--------|
| 1 | Learn shell, disclaimer, foundation | Done | Disclaimer, l10n, bundle-backed foundation; widget tests in `test/widget_test.dart`. |
| 2 | Profile-derived Learn signals | Done | `LearnProfileSignals`, `OnboardingGate.learnProfileSignalsOrNull()`, `test/features/learn/domain/learn_profile_signals_test.dart`; Learn catheter banner uses signals when profile present. |
| 3 | Anatomy track how-to | Done | Anatomy track section after foundation; prefs-backed override; privacy expansion; `test/features/learn/presentation/learn_screen_test.dart`. |
| 4 | Dos and don’ts | Not started | |
| 5 | Learn guided movement (MVP) | Not started | |
| 6 | Learn troubleshooter | Not started | |
| 7 | Learn suggested link | Not started | |
| 8 | Training pivot override | Not started | |
| 9 | Training surfaces — pivot and catheter | Not started | |

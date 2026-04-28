# Contributing to Kegel Master

Thank you for helping improve this project. This repo is a Flutter app; the main product targets are **Android** and **iOS** (see [README.md](README.md)).

## Before you start

1. Open an issue or comment on an existing one so maintainers can align on scope when the change is non-trivial.
2. Keep changes focused: one logical concern per pull request when possible.

## Development setup

- Install [Flutter](https://docs.flutter.dev/get-started/install) with a Dart SDK compatible with `^3.10.8` (see `environment` in [pubspec.yaml](pubspec.yaml)).
- From the repository root:

```bash
flutter pub get
flutter analyze
flutter test
```

Fix any new analyzer issues and failing tests before opening a PR.

## Dependencies: open source only

**New or upgraded dependencies must be open source** under a license that allows use, modification, and redistribution in this app (for example BSD-3-Clause, MIT, Apache-2.0, MPL-2.0, or another [OSI-approved](https://opensource.org/licenses) license you can point to).

When you add or bump a package:

1. **Check the package license** on [pub.dev](https://pub.dev) and in the package’s source repository (LICENSE file or `pubspec.yaml` `license` field). Do not introduce packages whose terms are proprietary, undisclosed, or unclear.
2. **Review transitive dependencies** with `dart pub deps` (or `flutter pub deps`) and ensure you are comfortable that the resolved tree remains consistent with this policy. If a transitive package has an unacceptable license, do not merge the change until that is resolved (different version, alternative package, or upstream fix).
3. **Git or path dependencies** are allowed only when that code is under a compatible open source license and the provenance is documented in the PR.
4. **SDK packages** (`flutter`, `flutter_test`, and other `sdk:` entries) are in scope of the Flutter/Dart open source stacks and are fine.

If you are unsure about a license, ask in the PR before merging.

## Pull requests

- Describe what changed and why (user-visible behavior, risks, and test coverage).
- Link related issues when applicable.
- Keep commits readable; squash or reorganize if the history would confuse reviewers.

## Code and structure

- Follow existing layout under [`lib/features/`](lib/features/) and patterns described in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).
- Match surrounding style, naming, and import conventions.

# App storage (Drift, session history, prefs mirror, streaks) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add local-first SQLite (Drift) storage for ended session runs and user preference rows (including optional `SessionConfig` mirror), pure streak derivation per `docs/superpowers/specs/2026-05-01-app-storage-design.md`, wire session completion to persistence, and centralize effective `SessionConfig` resolution.

**Architecture:** One Drift database file under the app documents directory; domain stays free of Flutter except where unavoidable (DB open uses `path_provider`). Two narrow store interfaces (`SessionHistoryStore`, `UserPreferencesStore`) with Drift implementations. Onboarding persistence stays separate (`SharedPreferences`). Streaks computed in pure Dart from completed-run dates bucketed with `endedAt.toLocal()` date-only.

**Tech Stack:** Flutter 3.x, Dart ^3.10, `drift` + `drift_dev` + `build_runner`, `sqlite3_flutter_libs` (mobile/desktop native SQLite), `path`, `path_provider`.

---

## File map (create / modify)

| Path | Responsibility |
|------|------------------|
| `pubspec.yaml` | Add drift, sqlite3_flutter_libs, path, path_provider, dev drift_dev + build_runner. |
| `lib/features/session/domain/session_config.dart` | Add `toJson` / `fromJson` for snapshot persistence (or adjacent codec file if you prefer not to grow the class). |
| `lib/features/progress/domain/session_outcome.dart` | Enum `completed` / `abandoned`. |
| `lib/features/progress/domain/session_run.dart` | Immutable value type matching spec fields. |
| `lib/features/progress/domain/streak_calculator.dart` | Qualifying-day set, `currentStreak`, `bestStreak`, `qualifyingLocalDatesFromEndedAt`. |
| `lib/features/progress/domain/effective_session_config.dart` | Pure resolver: mirror → prescription → defaults. |
| `lib/features/progress/application/session_history_store.dart` | Abstract API: `appendRun`, `watchRuns` / `listRunsInRange`, `qualifyingCompletedLocalDates` (or query raw for streak layer). |
| `lib/features/progress/application/user_preferences_store.dart` | Abstract API: `readMirror`, `writeMirror`, `clearMirror`, `schemaVersion`. |
| `lib/features/progress/data/drift/kegel_database.dart` | `@DriftDatabase` + includes; connection open helper. |
| `lib/features/progress/data/drift/tables.dart` | Drift table definitions. |
| `lib/features/progress/data/drift/kegel_database.g.dart` | Generated — do not hand-edit. |
| `lib/features/progress/data/drift_session_history_store.dart` | Implements `SessionHistoryStore`. |
| `lib/features/progress/data/drift_user_preferences_store.dart` | Implements `UserPreferencesStore` (single logical row `id = 1`). |
| `lib/features/progress/presentation/progress_scope.dart` | `InheritedWidget` exposing stores to subtree. |
| `lib/main.dart` | Open DB, construct stores, wrap app with `ProgressScope`. |
| `lib/app.dart` | Optional: no change if scope wraps inside `main`. |
| `lib/router/app_router.dart` | No signature change if `SessionScreen` uses `ProgressScope.of`; else pass nothing. |
| `lib/features/home/presentation/home_screen.dart` | Resolve config via `effective_session_config` + `ProgressScope` + `OnboardingScope`. |
| `lib/features/session/presentation/session_screen.dart` | Record `startedAt`; on `done` / `abandoned` append row once. |
| `lib/features/progress/presentation/progress_screen.dart` | Minimal: show `currentStreak` / placeholder count from store (validates wiring). |
| `test/streak_calculator_test.dart` | Unit tests for streak rules and bucketing. |
| `test/effective_session_config_test.dart` | Resolver precedence. |
| `test/drift_session_history_store_test.dart` | In-memory DB append + query. |

---

### Task 1: Dependencies and codegen wiring

**Files:**
- Modify: `pubspec.yaml`
- Create: `build.yaml` (optional empty drift config if defaults suffice)

**Add under `dependencies`:**

```yaml
  drift: ^2.26.0
  sqlite3_flutter_libs: ^0.5.28
  path: ^1.9.1
  path_provider: ^2.1.5
  uuid: ^4.5.1
```

**Add under `dev_dependencies`:**

```yaml
  drift_dev: ^2.26.0
  build_runner: ^2.5.0
```

- [ ] **Step 1:** Edit `pubspec.yaml` with the blocks above (adjust patch versions if `flutter pub get` resolves newer compatible set).

- [ ] **Step 2:** Run `flutter pub get`  
  **Expected:** Exit code 0, lockfile updated.

- [ ] **Step 3:** Commit  
  ```bash
  git add pubspec.yaml pubspec.lock
  git commit -m "chore: add drift and sqlite deps for app storage"
  ```

---

### Task 2: `SessionConfig` JSON snapshot

**Files:**
- Modify: `lib/features/session/domain/session_config.dart`

**Rationale:** Spec requires immutable JSON snapshot on each run; keep keys stable for migrations.

- [ ] **Step 1:** Write failing test `test/session_config_json_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';

void main() {
  test('roundtrip SessionConfig json', () {
    final SessionConfig original = SessionConfig(
      squeezeSeconds: 4,
      relaxSeconds: 6,
      bufferBetweenSetsSeconds: 8,
      repsPerSet: 12,
      targetSets: 2,
    );
    final json = original.toJson();
    final restored = SessionConfig.fromJson(json);
    expect(restored.squeezeSeconds, 4);
    expect(restored.relaxSeconds, 6);
    expect(restored.bufferBetweenSetsSeconds, 8);
    expect(restored.repsPerSet, 12);
    expect(restored.targetSets, 2);
  });
}
```

- [ ] **Step 2:** Run `flutter test test/session_config_json_test.dart`  
  **Expected:** FAIL (missing `toJson`/`fromJson`).

- [ ] **Step 3:** Implement on `SessionConfig` (instance methods):

```dart
  Map<String, Object?> toJson() => <String, Object?>{
        'squeezeSeconds': squeezeSeconds,
        'relaxSeconds': relaxSeconds,
        'bufferBetweenSetsSeconds': bufferBetweenSetsSeconds,
        'repsPerSet': repsPerSet,
        'targetSets': targetSets,
      };

  static SessionConfig fromJson(Map<String, Object?> json) {
    return SessionConfig(
      squeezeSeconds: json['squeezeSeconds']! as int,
      relaxSeconds: json['relaxSeconds']! as int,
      bufferBetweenSetsSeconds: json['bufferBetweenSetsSeconds']! as int,
      repsPerSet: json['repsPerSet']! as int,
      targetSets: json['targetSets']! as int,
    );
  }
```

- [ ] **Step 4:** Run `flutter test test/session_config_json_test.dart`  
  **Expected:** PASS.

- [ ] **Step 5:** Commit.

---

### Task 3: Streak calculator (TDD)

**Files:**
- Create: `lib/features/progress/domain/streak_calculator.dart`
- Create: `test/streak_calculator_test.dart`

**API to implement (names illustrative but keep consistent everywhere):**

```dart
import 'dart:collection';

DateTime dateOnlyLocal(DateTime utcInstant) {
  final DateTime l = utcInstant.toLocal();
  return DateTime(l.year, l.month, l.day);
}

Set<DateTime> qualifyingLocalDatesFromEndedAt(Iterable<DateTime> completedEndedAtUtc) {
  return completedEndedAtUtc.map(dateOnlyLocal).toSet();
}

int currentStreak({
  required Set<DateTime> qualifyingLocalDates,
  required DateTime now,
}) {
  final DateTime today = dateOnlyLocal(now);
  final DateTime yesterday = today.subtract(const Duration(days: 1));

  DateTime? anchor;
  if (qualifyingLocalDates.contains(today)) {
    anchor = today;
  } else if (qualifyingLocalDates.contains(yesterday)) {
    anchor = yesterday;
  } else {
    return 0;
  }

  var streak = 0;
  for (DateTime d = anchor; qualifyingLocalDates.contains(d); d = d.subtract(const Duration(days: 1))) {
    streak++;
  }
  return streak;
}

int bestStreak(Set<DateTime> qualifyingLocalDates) {
  if (qualifyingLocalDates.isEmpty) return 0;
  final List<DateTime> sorted = SplayTreeSet<DateTime>.from(qualifyingLocalDates).toList();
  var best = 1;
  var run = 1;
  for (var i = 1; i < sorted.length; i++) {
    final DateTime prev = sorted[i - 1];
    final DateTime cur = sorted[i];
    if (cur.difference(prev) == const Duration(days: 1)) {
      run++;
      if (run > best) best = run;
    } else {
      run = 1;
    }
  }
  return best;
}
```

- [ ] **Step 1:** Add `test/streak_calculator_test.dart` with cases:
  - `currentStreak`: today qualifies → counts chain backward.
  - `currentStreak`: today not qualifying, yesterday qualifies → anchor yesterday, streak includes yesterday and prior consecutive days.
  - `currentStreak`: neither today nor yesterday qualifies → `0` even if older qualifying days exist.
  - `bestStreak`: scattered vs one long run.

- [ ] **Step 2:** Run tests → FAIL until file exists.

- [ ] **Step 3:** Add `streak_calculator.dart` with the code above (adjust imports: `SplayTreeSet` from `dart:collection`).

- [ ] **Step 4:** `flutter test test/streak_calculator_test.dart` → PASS.

- [ ] **Step 5:** Commit.

---

### Task 4: Effective session config resolver (TDD)

**Files:**
- Create: `lib/features/progress/domain/effective_session_config.dart`
- Create: `test/effective_session_config_test.dart`

```dart
import 'package:kegel_master/features/onboarding/domain/onboarding_profile.dart';
import 'package:kegel_master/features/onboarding/domain/session_prescription.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';

SessionConfig resolveEffectiveSessionConfig({
  required SessionConfig? mirror,
  required bool onboardingComplete,
  required OnboardingProfile? profile,
}) {
  if (mirror != null) return mirror;
  if (onboardingComplete && profile != null) {
    return sessionPrescriptionFromProfile(profile);
  }
  return SessionConfig.defaults;
}
```

- [ ] **Step 1:** Tests: (1) mirror wins over profile. (2) null mirror + complete + profile → prescription. (3) null mirror + incomplete → defaults. (4) null mirror + complete + null profile → defaults.

- [ ] **Step 2:** Implement file; run `flutter test test/effective_session_config_test.dart` → PASS.

- [ ] **Step 3:** Commit.

---

### Task 5: Drift schema and generated database

**Files:**
- Create: `lib/features/progress/data/drift/tables.dart`
- Create: `lib/features/progress/data/drift/kegel_database.dart`
- Generated: `lib/features/progress/data/drift/kegel_database.g.dart`

**`tables.dart`:**

```dart
import 'package:drift/drift.dart';

class SessionRuns extends Table {
  TextColumn get id => text()();
  IntColumn get startedAtMs => integer()();
  IntColumn get endedAtMs => integer()();
  TextColumn get configJson => text()();
  TextColumn get outcome => text()();
  IntColumn get skippedPhaseCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class UserPreferenceRows extends Table {
  IntColumn get id => integer()();
  IntColumn get schemaVersion => integer()();
  TextColumn get sessionConfigMirrorJson => text().nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}
```

**`kegel_database.dart` (skeleton — adjust import part path after codegen):**

```dart
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'kegel_database.g.dart';

@DriftDatabase(tables: [SessionRuns, UserPreferenceRows])
class KegelDatabase extends _$KegelDatabase {
  KegelDatabase(super.e);

  @override
  int get schemaVersion => 1;
}

LazyDatabase openKegelDatabaseConnection() {
  return LazyDatabase(() async {
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'kegel_progress.sqlite'));
      return NativeDatabase.createInBackground(file);
    }
    return NativeDatabase.memory();
  });
}
```

- [ ] **Step 1:** Add both Dart files with `part 'kegel_database.g.dart';`.

- [ ] **Step 2:** Run `dart run build_runner build --delete-conflicting-outputs`  
  **Expected:** Generates `kegel_database.g.dart` without errors.

- [ ] **Step 3:** If analyzer complains on web target: either exclude Drift from web build for this milestone or add conditional imports per Drift docs — **prefer** documenting “storage MVP targets mobile/desktop first” in commit message if web is out of scope.

- [ ] **Step 4:** Commit Dart + generated file.

---

### Task 6: Store interfaces + Drift implementations

**Files:**
- Create: `lib/features/progress/application/session_history_store.dart`
- Create: `lib/features/progress/application/user_preferences_store.dart`
- Create: `lib/features/progress/data/drift_session_history_store.dart`
- Create: `lib/features/progress/data/drift_user_preferences_store.dart`

**Abstract session history (example):**

```dart
import 'package:kegel_master/features/progress/domain/session_run.dart';

abstract class SessionHistoryStore {
  Future<void> appendRun(SessionRun run);
  Future<List<SessionRun>> listAllRuns();
  Future<Iterable<DateTime>> completedEndedAtUtc();
}
```

**`SessionRun` value type** (`lib/features/progress/domain/session_run.dart`): fields match spec; `fromDriftRow` / `toCompanion` in impl file to avoid drift types in domain if desired — acceptable to map in data layer.

**Append implementation sketch** (`drift_session_history_store.dart`):

```dart
  @override
  Future<void> appendRun(SessionRun run) async {
    await _db.into(_db.sessionRuns).insert(
          SessionRunsCompanion.insert(
            id: run.id,
            startedAtMs: run.startedAt.millisecondsSinceEpoch,
            endedAtMs: run.endedAt.millisecondsSinceEpoch,
            configJson: /* jsonEncode SessionConfig */,
            outcome: run.outcome.name,
            skippedPhaseCount: run.skippedPhaseCount,
          ),
          mode: InsertMode.insertOrFail,
        );
  }
```

Use `dart:convert` `jsonEncode` for `configJson` from `run.configSnapshot.toJson()`.

**User prefs store:** `ensureSeedRow()` inserts `id = 1`, `schemaVersion = 1`, null mirror if missing. `readMirror` parses JSON or returns null. `writeMirror` updates row 1.

- [ ] **Step 1:** Write `test/drift_session_history_store_test.dart` using in-memory executor:

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kegel_master/features/progress/data/drift/kegel_database.dart';
import 'package:kegel_master/features/progress/domain/session_outcome.dart';
import 'package:kegel_master/features/progress/domain/session_run.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';

void main() {
  test('append and list runs', () async {
    final db = KegelDatabase(NativeDatabase.memory());
    final store = DriftSessionHistoryStore(db);
    final run = SessionRun(
      id: 'a',
      startedAt: DateTime.utc(2026, 5, 1, 10),
      endedAt: DateTime.utc(2026, 5, 1, 10, 20),
      configSnapshot: SessionConfig.defaults,
      outcome: SessionOutcome.completed,
      skippedPhaseCount: 0,
    );
    await store.appendRun(run);
    final all = await store.listAllRuns();
    expect(all.length, 1);
    expect(all.single.id, 'a');
    await db.close();
  });
}
```

- [ ] **Step 2:** Run test → FAIL until impl exists.

- [ ] **Step 3:** Implement domain `SessionRun`, `SessionOutcome`, Drift stores, mapping.

- [ ] **Step 4:** `flutter test test/drift_session_history_store_test.dart` → PASS.

- [ ] **Step 5:** Commit.

---

### Task 7: `ProgressScope` and `main.dart` wiring

**Files:**
- Create: `lib/features/progress/presentation/progress_scope.dart`
- Modify: `lib/main.dart`

**`progress_scope.dart`:**

```dart
import 'package:flutter/widgets.dart';
import 'package:kegel_master/features/progress/application/session_history_store.dart';
import 'package:kegel_master/features/progress/application/user_preferences_store.dart';

class ProgressScope extends InheritedWidget {
  const ProgressScope({
    super.key,
    required this.sessionHistory,
    required this.userPreferences,
    required super.child,
  });

  final SessionHistoryStore sessionHistory;
  final UserPreferencesStore userPreferences;

  static ProgressScope of(BuildContext context) {
    final ProgressScope? scope =
        context.dependOnInheritedWidgetOfExactType<ProgressScope>();
    assert(scope != null, 'ProgressScope not found');
    return scope!;
  }

  @override
  bool updateShouldNotify(ProgressScope oldWidget) =>
      sessionHistory != oldWidget.sessionHistory ||
      userPreferences != oldWidget.userPreferences;
}
```

**`main.dart` sketch:**

```dart
  final LazyDatabase lazyDb = openKegelDatabaseConnection();
  final KegelDatabase db = KegelDatabase(lazyDb);
  final DriftSessionHistoryStore sessionHistory = DriftSessionHistoryStore(db);
  final DriftUserPreferencesStore userPreferences = DriftUserPreferencesStore(db);
  await userPreferences.ensureSeedRow();
```

Wrap `OnboardingScope` child with `ProgressScope(...)` **inside** the same `runApp` tree so `/session` and shell routes can call `ProgressScope.of(context)`.

Add `import 'package:drift/drift.dart';` in `main.dart` if you reference `LazyDatabase` there, or keep `openKegelDatabaseConnection` return type inferred from `kegel_database.dart` exports.

- [ ] **Step 1:** Implement scope + main wiring.

- [ ] **Step 2:** `flutter analyze`  
  **Expected:** No new errors.

- [ ] **Step 3:** Commit.

---

### Task 8: Home uses resolver; session persists runs

**Files:**
- Modify: `lib/features/home/presentation/home_screen.dart`
- Modify: `lib/features/session/presentation/session_screen.dart`

**Home:** Replace direct `OnboardingScope.of(context).currentSessionConfigOrNull() ?? SessionConfig.defaults` with `resolveEffectiveSessionConfig(mirror: ..., onboardingComplete: gate.snapshot.onboardingComplete, profile: gate.snapshot.profile)` where `mirror` comes from `ProgressScope.of(context).userPreferences.readMirror()`.

If `readMirror` is `Future<SessionConfig?>`, wrap the start button in a `FutureBuilder` that depends on a `Future` combining prefs + gate (or add a tiny `ChangeNotifier` that loads mirror once at startup and on mirror writes — **prefer** `FutureBuilder` for MVP to avoid new state types).

**SessionScreen:**

- Field `late final DateTime _sessionStartedAt = DateTime.now().toUtc();`
- After `_engine` reaches `done` or `abandoned`, call `_persistRunOnce()` guarded by a `bool _persisted` flag.
- UUID: `import 'package:uuid/uuid.dart';` and `const Uuid().v4()` (dependency added in Task 1).

**Persist payload:**

```dart
final run = SessionRun(
  id: const Uuid().v4(),
  startedAt: _sessionStartedAt,
  endedAt: DateTime.now().toUtc(),
  configSnapshot: _config,
  outcome: s.isCompleted ? SessionOutcome.completed : SessionOutcome.abandoned,
  skippedPhaseCount: s.skippedPhaseCount,
);
await ProgressScope.of(context).sessionHistory.appendRun(run);
```

Invoke persistence when timer ends in `_onTick` after phase transition, and after `endEarly()` confirm path, and when `done` UI shows — **single** call site: private `_onEngineTerminal(SessionState s)` from both tick and end-early.

- [ ] **Step 1:** Manual run on device/emulator: complete one session, verify sqlite file or add temporary debug print.

- [ ] **Step 2:** `flutter test` (full suite).

- [ ] **Step 3:** Commit.

---

### Task 9: Progress tab shows streak (smoke UI)

**Files:**
- Modify: `lib/features/progress/presentation/progress_screen.dart`

- [ ] **Step 1:** On build, `FutureBuilder` or `StreamBuilder` loading `completedEndedAtUtc` from `SessionHistoryStore`, map through `qualifyingLocalDatesFromEndedAt`, compute `currentStreak(now: DateTime.now())`, display as `Text('Current streak: $n days')`.

- [ ] **Step 2:** `flutter test` still green.

- [ ] **Step 3:** Commit.

---

## Spec coverage checklist (self-review)

| Spec section | Task(s) |
|--------------|---------|
| Append-only run at end, outcomes, skipped count, UTC `startedAt`/`endedAt`, config snapshot | Task 2, 5, 6, 8 |
| Calendar bucketing `endedAt` local date-only | Task 3 |
| Current / best streak rules | Task 3 |
| User prefs row + mirror nullable | Task 5, 6 |
| Effective config resolution order | Task 4, 8 |
| Onboarding persistence separate | (unchanged) + Task 7 does not migrate onboarding |
| Local-first, Firebase seam (future) | Interfaces in Task 6 allow second impl; no Firebase in this plan |
| Transactions / errors | Use single `insert` in transaction if batching later; surface `try/catch` in UI optional for MVP |
| Tests | Tasks 2–4, 6, full suite Task 8 |

**Placeholder scan:** None intentional; `uuid` dependency named explicitly when chosen.

**Type consistency:** `SessionOutcome.name` stored as text; parse with `SessionOutcome.values.byName` on read.

---

## Execution handoff

Plan complete and saved to `docs/superpowers/plans/2026-05-01-app-storage.md`. Two execution options:

**1. Subagent-Driven (recommended)** — Dispatch a fresh subagent per task, review between tasks, fast iteration.

**2. Inline Execution** — Execute tasks in this session using executing-plans, batch execution with checkpoints.

Which approach do you want?

After implementation, run `flutter analyze` and `flutter test` before claiming the milestone done.

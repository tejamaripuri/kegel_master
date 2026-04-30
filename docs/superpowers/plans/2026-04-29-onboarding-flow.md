# Onboarding flow implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the v1 onboarding flow from [2026-04-29-onboarding-flow-design.md](../specs/2026-04-29-onboarding-flow-design.md): disclaimer and questionnaire, local persistence, GoRouter redirects (including catheter Learn-only mode), Settings reset, and `SessionConfig` derived from profile (excluding symptoms and excluding catheter for numeric tuning).

**Architecture:** Pure Dart domain (`OnboardingProfile`, mutual-exclusion rules, `sessionPrescriptionFromProfile`, `resolveOnboardingRedirect`) plus `shared_preferences` persistence behind a small interface. A `ChangeNotifier` gate loads the snapshot at startup and notifies `GoRouter` (`refreshListenable`) after save/reset. `main()` awaits `SharedPreferences.getInstance()` before building the router. Presentation uses a single full-screen onboarding flow widget (internal step index) and optional safety step after summary when catheter is selected.

**Tech Stack:** Flutter 3.x, Dart ^3.10, `go_router` ^17.x, `shared_preferences` (new dependency), existing `SessionConfig` / `SessionScreen`.

---

## File map (create / modify)

| Path | Responsibility |
|------|----------------|
| `pubspec.yaml` | Add `shared_preferences` dependency. |
| `lib/main.dart` | `WidgetsFlutterBinding.ensureInitialized()`, async prefs, build `OnboardingGate` + `createAppRouter`, `runApp`. |
| `lib/app.dart` | Optional: accept no change if router passed from `main`; keep `KegelMasterApp(router: …)`. |
| `lib/features/session/domain/session_config.dart` | Add `copyWith` for tuning prescription without repeating all fields. |
| `lib/features/onboarding/domain/onboarding_profile.dart` | Enums + `OnboardingProfile` immutable model + `toJson` / `fromJson`. |
| `lib/features/onboarding/domain/onboarding_mutual_exclusion.dart` | Pure helpers: toggle symptom with `none` exclusivity; same for clinical history. |
| `lib/features/onboarding/domain/onboarding_snapshot.dart` | Immutable snapshot: `onboardingComplete`, `disclaimerAcceptedAt`, `profile` nullable, `catheterActive`. |
| `lib/features/onboarding/domain/onboarding_redirect.dart` | Pure `resolveOnboardingRedirect(String path, OnboardingSnapshot s) → String?`. |
| `lib/features/onboarding/domain/session_prescription.dart` | `SessionConfig sessionPrescriptionFromProfile(OnboardingProfile p)`. |
| `lib/features/onboarding/data/onboarding_persistence.dart` | `OnboardingPersistence` abstract class + `SharedPreferencesOnboardingPersistence` reading/writing JSON blob + flags. |
| `lib/features/onboarding/application/onboarding_gate.dart` | `ChangeNotifier`: `load()`, `saveProfile(...)`, `reset()`, exposes `OnboardingSnapshot`. |
| `lib/features/onboarding/presentation/onboarding_scope.dart` | `InheritedNotifier<OnboardingGate>` for descendant screens. |
| `lib/features/onboarding/presentation/onboarding_flow_screen.dart` | Wizard UI: disclaimer → questions → summary → (safety if catheter) → calls gate + `context.go`. |
| `lib/router/app_router.dart` | Add `/onboarding` route; inject gate; `redirect` + `refreshListenable`; `/session` reads `extra` as `SessionConfig`. |
| `lib/features/home/presentation/home_screen.dart` | Resolve `SessionConfig` from scope + push `/session` with `extra`. |
| `lib/features/learn/presentation/learn_screen.dart` | `MaterialBanner` or top `Banner` when `catheterActive`. |
| `lib/features/settings/presentation/settings_screen.dart` | Reset onboarding button + confirm dialog. |
| `test/features/onboarding/domain/onboarding_mutual_exclusion_test.dart` | None exclusivity tests. |
| `test/features/onboarding/domain/onboarding_redirect_test.dart` | Redirect matrix. |
| `test/features/onboarding/domain/session_prescription_test.dart` | Representative `fromProfile` outputs; symptoms ignored. |

---

### Task 1: Dependencies and `SessionConfig.copyWith`

**Files:**

- Modify: `e:\Projects\Repos\kegel_master\pubspec.yaml`
- Modify: `e:\Projects\Repos\kegel_master\lib\features\session\domain\session_config.dart`

- [ ] **Step 1: Add dependency**

Under `dependencies:` in `pubspec.yaml`, add:

```yaml
  shared_preferences: ^2.5.3
```

- [ ] **Step 2: Fetch packages**

Run:

```text
flutter pub get
```

Expected: ends with `Got dependencies!` (or equivalent) and exit code 0.

- [ ] **Step 3: Add `copyWith` to `SessionConfig`**

In `session_config.dart`, after the factory constructor and before the closing of the class, add:

```dart
  SessionConfig copyWith({
    int? squeezeSeconds,
    int? relaxSeconds,
    int? bufferBetweenSetsSeconds,
    int? repsPerSet,
    int? targetSets,
  }) {
    return SessionConfig(
      squeezeSeconds: squeezeSeconds ?? this.squeezeSeconds,
      relaxSeconds: relaxSeconds ?? this.relaxSeconds,
      bufferBetweenSetsSeconds:
          bufferBetweenSetsSeconds ?? this.bufferBetweenSetsSeconds,
      repsPerSet: repsPerSet ?? this.repsPerSet,
      targetSets: targetSets ?? this.targetSets,
    );
  }
```

- [ ] **Step 4: Run analyzer**

Run:

```text
dart analyze lib/features/session/domain/session_config.dart
```

Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/features/session/domain/session_config.dart
git commit -m "chore: add shared_preferences; SessionConfig.copyWith for prescriptions"
```

---

### Task 2: Domain model and JSON (`OnboardingProfile`)

**Files:**

- Create: `e:\Projects\Repos\kegel_master\lib\features\onboarding\domain\onboarding_profile.dart`

- [ ] **Step 1: Create enums and profile class**

Create `onboarding_profile.dart` with this full content:

```dart
enum GenderIdentity { male, female, nonBinary }

enum PrimaryGoal {
  postpartumRecovery,
  postSurgicalProstateRecovery,
  preventionMaintenance,
  sexualPerformanceEnhancement,
  incontinenceManagement,
}

enum AgeBand { age18to34, age35to54, age55plus }

enum Symptom {
  leakingCoughSneeze,
  suddenUrges,
  difficultyStartingStream,
  chronicPelvicPain,
  none,
}

enum ClinicalHistory {
  birthWithin8Weeks,
  recentProstateSurgery,
  catheter,
  none,
}

class OnboardingProfile {
  const OnboardingProfile({
    required this.gender,
    required this.primaryGoal,
    required this.ageBand,
    required this.symptoms,
    required this.clinicalHistory,
  });

  final GenderIdentity gender;
  final PrimaryGoal primaryGoal;
  final AgeBand ageBand;
  final Set<Symptom> symptoms;
  final Set<ClinicalHistory> clinicalHistory;

  bool get hasCatheter => clinicalHistory.contains(ClinicalHistory.catheter);

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'gender': gender.name,
      'primaryGoal': primaryGoal.name,
      'ageBand': ageBand.name,
      'symptoms': symptoms.map((e) => e.name).toList(),
      'clinicalHistory': clinicalHistory.map((e) => e.name).toList(),
    };
  }

  static OnboardingProfile fromJson(Map<String, Object?> json) {
    return OnboardingProfile(
      gender: GenderIdentity.values.byName(json['gender']! as String),
      primaryGoal: PrimaryGoal.values.byName(json['primaryGoal']! as String),
      ageBand: AgeBand.values.byName(json['ageBand']! as String),
      symptoms: (json['symptoms']! as List<dynamic>)
          .map((e) => Symptom.values.byName(e as String))
          .toSet(),
      clinicalHistory: (json['clinicalHistory']! as List<dynamic>)
          .map((e) => ClinicalHistory.values.byName(e as String))
          .toSet(),
    );
  }
}
```

- [ ] **Step 2: Analyze**

Run:

```text
dart analyze lib/features/onboarding/domain/onboarding_profile.dart
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/features/onboarding/domain/onboarding_profile.dart
git commit -m "feat(onboarding): add OnboardingProfile and enums with JSON"
```

---

### Task 3: Mutual exclusion helpers (TDD)

**Files:**

- Create: `e:\Projects\Repos\kegel_master\lib\features\onboarding\domain\onboarding_mutual_exclusion.dart`
- Create: `e:\Projects\Repos\kegel_master\test\features\onboarding\domain\onboarding_mutual_exclusion_test.dart`

- [ ] **Step 1: Write failing tests**

Create `onboarding_mutual_exclusion_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_mutual_exclusion.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_profile.dart';

void main() {
  group('symptoms', () {
    test('selecting none clears other symptoms', () {
      final Set<Symptom> start = {
        Symptom.leakingCoughSneeze,
        Symptom.suddenUrges,
      };
      final Set<Symptom> out =
          OnboardingMutualExclusion.toggleSymptom(start, Symptom.none);
      expect(out, equals(<Symptom>{Symptom.none}));
    });

    test('selecting non-none clears none', () {
      final Set<Symptom> start = {Symptom.none};
      final Set<Symptom> out = OnboardingMutualExclusion.toggleSymptom(
        start,
        Symptom.chronicPelvicPain,
      );
      expect(out, equals(<Symptom>{Symptom.chronicPelvicPain}));
    });
  });

  group('clinicalHistory', () {
    test('selecting none clears other flags', () {
      final Set<ClinicalHistory> start = {
        ClinicalHistory.birthWithin8Weeks,
      };
      final Set<ClinicalHistory> out =
          OnboardingMutualExclusion.toggleClinicalHistory(
        start,
        ClinicalHistory.none,
      );
      expect(out, equals(<ClinicalHistory>{ClinicalHistory.none}));
    });

    test('selecting catheter clears none', () {
      final Set<ClinicalHistory> start = {ClinicalHistory.none};
      final Set<ClinicalHistory> out =
          OnboardingMutualExclusion.toggleClinicalHistory(
        start,
        ClinicalHistory.catheter,
      );
      expect(out, equals(<ClinicalHistory>{ClinicalHistory.catheter}));
    });
  });
}
```

- [ ] **Step 2: Run tests (expect compile failure)**

Run:

```text
flutter test test/features/onboarding/domain/onboarding_mutual_exclusion_test.dart
```

Expected: failure referencing missing `OnboardingMutualExclusion`.

- [ ] **Step 3: Implement helpers**

Create `onboarding_mutual_exclusion.dart`:

```dart
import 'package:kegel_master/features/onboarding/domain/onboarding_profile.dart';

class OnboardingMutualExclusion {
  const OnboardingMutualExclusion._();

  static Set<Symptom> toggleSymptom(Set<Symptom> current, Symptom tapped) {
    if (tapped == Symptom.none) {
      return <Symptom>{Symptom.none};
    }
    final Set<Symptom> next = Set<Symptom>.from(current)..remove(Symptom.none);
    if (next.contains(tapped)) {
      next.remove(tapped);
    } else {
      next.add(tapped);
    }
    if (next.isEmpty) {
      return <Symptom>{Symptom.none};
    }
    return next;
  }

  static Set<ClinicalHistory> toggleClinicalHistory(
    Set<ClinicalHistory> current,
    ClinicalHistory tapped,
  ) {
    if (tapped == ClinicalHistory.none) {
      return <ClinicalHistory>{ClinicalHistory.none};
    }
    final Set<ClinicalHistory> next = Set<ClinicalHistory>.from(current)
      ..remove(ClinicalHistory.none);
    if (next.contains(tapped)) {
      next.remove(tapped);
    } else {
      next.add(tapped);
    }
    if (next.isEmpty) {
      return <ClinicalHistory>{ClinicalHistory.none};
    }
    return next;
  }
}
```

- [ ] **Step 4: Run tests (expect pass)**

Run:

```text
flutter test test/features/onboarding/domain/onboarding_mutual_exclusion_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/features/onboarding/domain/onboarding_mutual_exclusion.dart test/features/onboarding/domain/onboarding_mutual_exclusion_test.dart
git commit -m "feat(onboarding): mutual exclusion for None in symptoms and clinical history"
```

---

### Task 4: `OnboardingSnapshot` and pure redirect (TDD)

**Files:**

- Create: `e:\Projects\Repos\kegel_master\lib\features\onboarding\domain\onboarding_snapshot.dart`
- Create: `e:\Projects\Repos\kegel_master\lib\features\onboarding\domain\onboarding_redirect.dart`
- Create: `e:\Projects\Repos\kegel_master\test\features\onboarding\domain\onboarding_redirect_test.dart`

- [ ] **Step 1: Snapshot + redirect implementation**

Create `onboarding_snapshot.dart`:

```dart
import 'package:kegel_master/features/onboarding/domain/onboarding_profile.dart';

class OnboardingSnapshot {
  const OnboardingSnapshot({
    required this.onboardingComplete,
    required this.catheterActive,
    this.disclaimerAcceptedAt,
    this.profile,
  });

  final bool onboardingComplete;
  final bool catheterActive;
  final DateTime? disclaimerAcceptedAt;
  final OnboardingProfile? profile;

  static const OnboardingSnapshot empty = OnboardingSnapshot(
    onboardingComplete: false,
    catheterActive: false,
  );
}
```

Create `onboarding_redirect.dart`:

```dart
import 'package:kegel_master/features/onboarding/domain/onboarding_snapshot.dart';

String? resolveOnboardingRedirect({
  required String path,
  required OnboardingSnapshot snapshot,
}) {
  if (!snapshot.onboardingComplete) {
    if (path == '/onboarding') {
      return null;
    }
    return '/onboarding';
  }

  if (snapshot.catheterActive) {
    const allowed = <String>{'/learn', '/settings', '/onboarding'};
    if (allowed.contains(path)) {
      return null;
    }
    if (path == '/home' || path == '/progress' || path == '/session') {
      return '/learn';
    }
    return '/learn';
  }

  return null;
}
```

Note: The final `return '/learn'` covers shell-only navigation edge cases where `path` might not be one of the four tab paths depending on `go_router` / shell reporting; if integration tests show double redirects, narrow this branch to known blocked paths only.

- [ ] **Step 2: Write redirect tests**

Create `onboarding_redirect_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_profile.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_redirect.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_snapshot.dart';

OnboardingProfile _minimalProfile({required bool catheter}) {
  return OnboardingProfile(
    gender: GenderIdentity.female,
    primaryGoal: PrimaryGoal.preventionMaintenance,
    ageBand: AgeBand.age18to34,
    symptoms: {Symptom.chronicPelvicPain},
    clinicalHistory: catheter
        ? {ClinicalHistory.catheter}
        : {ClinicalHistory.none},
  );
}

void main() {
  test('incomplete onboarding sends /home to /onboarding', () {
    expect(
      resolveOnboardingRedirect(
        path: '/home',
        snapshot: OnboardingSnapshot.empty,
      ),
      '/onboarding',
    );
  });

  test('incomplete allows /onboarding', () {
    expect(
      resolveOnboardingRedirect(
        path: '/onboarding',
        snapshot: OnboardingSnapshot.empty,
      ),
      isNull,
    );
  });

  test('complete + catheter blocks /session to /learn', () {
    final OnboardingSnapshot s = OnboardingSnapshot(
      onboardingComplete: true,
      catheterActive: true,
      profile: _minimalProfile(catheter: true),
    );
    expect(resolveOnboardingRedirect(path: '/session', snapshot: s), '/learn');
  });

  test('complete + catheter allows /settings', () {
    final OnboardingSnapshot s = OnboardingSnapshot(
      onboardingComplete: true,
      catheterActive: true,
      profile: _minimalProfile(catheter: true),
    );
    expect(resolveOnboardingRedirect(path: '/settings', snapshot: s), isNull);
  });

  test('complete + catheter redirects /home to /learn', () {
    final OnboardingSnapshot s = OnboardingSnapshot(
      onboardingComplete: true,
      catheterActive: true,
      profile: _minimalProfile(catheter: true),
    );
    expect(resolveOnboardingRedirect(path: '/home', snapshot: s), '/learn');
  });

  test('complete + catheter with pain in profile still catheter rules', () {
    final OnboardingSnapshot s = OnboardingSnapshot(
      onboardingComplete: true,
      catheterActive: true,
      profile: _minimalProfile(catheter: true),
    );
    expect(resolveOnboardingRedirect(path: '/session', snapshot: s), '/learn');
  });

  test('complete without catheter allows /home', () {
    final OnboardingSnapshot s = OnboardingSnapshot(
      onboardingComplete: true,
      catheterActive: false,
      profile: _minimalProfile(catheter: false),
    );
    expect(resolveOnboardingRedirect(path: '/home', snapshot: s), isNull);
  });
}
```

- [ ] **Step 3: Run tests**

Run:

```text
flutter test test/features/onboarding/domain/onboarding_redirect_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 4: Commit**

```bash
git add lib/features/onboarding/domain/onboarding_snapshot.dart lib/features/onboarding/domain/onboarding_redirect.dart test/features/onboarding/domain/onboarding_redirect_test.dart
git commit -m "feat(onboarding): snapshot model and pure redirect resolver"
```

---

### Task 5: `sessionPrescriptionFromProfile` (TDD)

**Files:**

- Create: `e:\Projects\Repos\kegel_master\lib\features\onboarding\domain\session_prescription.dart`
- Create: `e:\Projects\Repos\kegel_master\test\features\onboarding\domain\session_prescription_test.dart`

- [ ] **Step 1: Implement prescription (single module of tunable numbers)**

Create `session_prescription.dart`:

```dart
import 'package:kegel_master/features/onboarding/domain/onboarding_profile.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';

SessionConfig sessionPrescriptionFromProfile(OnboardingProfile profile) {
  SessionConfig c = SessionConfig.defaults;

  switch (profile.ageBand) {
    case AgeBand.age18to34:
      break;
    case AgeBand.age35to54:
      c = c.copyWith(
        relaxSeconds: c.relaxSeconds + 2,
        bufferBetweenSetsSeconds: c.bufferBetweenSetsSeconds + 2,
      );
      break;
    case AgeBand.age55plus:
      c = c.copyWith(
        relaxSeconds: c.relaxSeconds + 4,
        bufferBetweenSetsSeconds: c.bufferBetweenSetsSeconds + 4,
        repsPerSet: 8,
        targetSets: 2,
      );
      break;
  }

  switch (profile.primaryGoal) {
    case PrimaryGoal.postpartumRecovery:
    case PrimaryGoal.postSurgicalProstateRecovery:
      c = c.copyWith(
        repsPerSet: (c.repsPerSet - 2).clamp(1, 1000),
        targetSets: (c.targetSets - 1).clamp(1, 1000),
        bufferBetweenSetsSeconds: c.bufferBetweenSetsSeconds + 5,
      );
      break;
    case PrimaryGoal.preventionMaintenance:
      break;
    case PrimaryGoal.sexualPerformanceEnhancement:
      c = c.copyWith(
        squeezeSeconds: c.squeezeSeconds + 1,
        relaxSeconds: (c.relaxSeconds - 1).clamp(0, 1000),
      );
      break;
    case PrimaryGoal.incontinenceManagement:
      c = c.copyWith(
        repsPerSet: c.repsPerSet + 2,
        bufferBetweenSetsSeconds: c.bufferBetweenSetsSeconds + 2,
      );
      break;
  }

  final bool gentleClinical = profile.clinicalHistory.contains(
        ClinicalHistory.birthWithin8Weeks,
      ) ||
      profile.clinicalHistory.contains(ClinicalHistory.recentProstateSurgery);
  if (gentleClinical) {
    c = c.copyWith(
      bufferBetweenSetsSeconds: c.bufferBetweenSetsSeconds + 2,
    );
  }

  return SessionConfig(
    squeezeSeconds: c.squeezeSeconds,
    relaxSeconds: c.relaxSeconds,
    bufferBetweenSetsSeconds: c.bufferBetweenSetsSeconds,
    repsPerSet: c.repsPerSet,
    targetSets: c.targetSets,
  );
}
```

Symptoms are intentionally not read (per spec).

- [ ] **Step 2: Write tests**

Create `session_prescription_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_profile.dart';
import 'package:kegel_master/features/onboarding/domain/session_prescription.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';

OnboardingProfile _base({
  required Set<Symptom> symptoms,
  Set<ClinicalHistory> clinical = const {ClinicalHistory.none},
}) {
  return OnboardingProfile(
    gender: GenderIdentity.male,
    primaryGoal: PrimaryGoal.preventionMaintenance,
    ageBand: AgeBand.age18to34,
    symptoms: symptoms,
    clinicalHistory: clinical,
  );
}

void main() {
  test('symptoms do not change prescription', () {
    final OnboardingProfile a = _base(symptoms: {Symptom.none});
    final OnboardingProfile b = _base(
      symptoms: {Symptom.chronicPelvicPain, Symptom.suddenUrges},
    );
    expect(
      sessionPrescriptionFromProfile(a).relaxSeconds,
      sessionPrescriptionFromProfile(b).relaxSeconds,
    );
    expect(
      sessionPrescriptionFromProfile(a).repsPerSet,
      sessionPrescriptionFromProfile(b).repsPerSet,
    );
  });

  test('age 55+ increases relax and buffer and lowers volume', () {
    final OnboardingProfile p = OnboardingProfile(
      gender: GenderIdentity.nonBinary,
      primaryGoal: PrimaryGoal.preventionMaintenance,
      ageBand: AgeBand.age55plus,
      symptoms: {Symptom.none},
      clinicalHistory: {ClinicalHistory.none},
    );
    final SessionConfig c = sessionPrescriptionFromProfile(p);
    expect(c.relaxSeconds, greaterThan(SessionConfig.defaults.relaxSeconds));
    expect(
      c.bufferBetweenSetsSeconds,
      greaterThan(SessionConfig.defaults.bufferBetweenSetsSeconds),
    );
    expect(c.repsPerSet, lessThan(SessionConfig.defaults.repsPerSet));
  });

  test('postpartum goal gentler than defaults at same age', () {
    final SessionConfig prevention = sessionPrescriptionFromProfile(
      OnboardingProfile(
        gender: GenderIdentity.female,
        primaryGoal: PrimaryGoal.preventionMaintenance,
        ageBand: AgeBand.age18to34,
        symptoms: {Symptom.none},
        clinicalHistory: {ClinicalHistory.none},
      ),
    );
    final SessionConfig postpartum = sessionPrescriptionFromProfile(
      OnboardingProfile(
        gender: GenderIdentity.female,
        primaryGoal: PrimaryGoal.postpartumRecovery,
        ageBand: AgeBand.age18to34,
        symptoms: {Symptom.none},
        clinicalHistory: {ClinicalHistory.none},
      ),
    );
    expect(postpartum.repsPerSet, lessThanOrEqualTo(prevention.repsPerSet));
  });
}
```

- [ ] **Step 3: Run tests**

Run:

```text
flutter test test/features/onboarding/domain/session_prescription_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 4: Commit**

```bash
git add lib/features/onboarding/domain/session_prescription.dart test/features/onboarding/domain/session_prescription_test.dart
git commit -m "feat(onboarding): session prescription from profile (symptoms excluded)"
```

---

### Task 6: Persistence + `OnboardingGate`

**Files:**

- Create: `e:\Projects\Repos\kegel_master\lib\features\onboarding\data\onboarding_persistence.dart`
- Create: `e:\Projects\Repos\kegel_master\lib\features\onboarding\application\onboarding_gate.dart`

- [ ] **Step 1: Persistence interface and implementation**

Create `onboarding_persistence.dart`:

```dart
import 'dart:convert';

import 'package:kegel_master/features/onboarding/domain/onboarding_profile.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_snapshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class OnboardingPersistence {
  Future<OnboardingSnapshot> readSnapshot();
  Future<void> writeSnapshot(OnboardingSnapshot snapshot);
  Future<void> clear();
}

class SharedPreferencesOnboardingPersistence implements OnboardingPersistence {
  SharedPreferencesOnboardingPersistence(this._prefs);

  final SharedPreferences _prefs;

  static const String _keySchema = 'onboarding_schema_version';
  static const String _keyComplete = 'onboarding_complete';
  static const String _keyCatheter = 'onboarding_catheter_active';
  static const String _keyDisclaimer = 'onboarding_disclaimer_accepted_at';
  static const String _keyProfileJson = 'onboarding_profile_json';

  static const int _schemaVersion = 1;

  @override
  Future<OnboardingSnapshot> readSnapshot() async {
    final bool complete = _prefs.getBool(_keyComplete) ?? false;
    final bool catheter = _prefs.getBool(_keyCatheter) ?? false;
    final String? disclaimerIso = _prefs.getString(_keyDisclaimer);
    final String? profileJson = _prefs.getString(_keyProfileJson);
    OnboardingProfile? profile;
    if (profileJson != null && profileJson.isNotEmpty) {
      profile = OnboardingProfile.fromJson(
        jsonDecode(profileJson) as Map<String, Object?>,
      );
    }
    return OnboardingSnapshot(
      onboardingComplete: complete,
      catheterActive: catheter,
      disclaimerAcceptedAt: disclaimerIso == null
          ? null
          : DateTime.tryParse(disclaimerIso),
      profile: profile,
    );
  }

  @override
  Future<void> writeSnapshot(OnboardingSnapshot snapshot) async {
    await _prefs.setInt(_keySchema, _schemaVersion);
    await _prefs.setBool(_keyComplete, snapshot.onboardingComplete);
    await _prefs.setBool(_keyCatheter, snapshot.catheterActive);
    if (snapshot.disclaimerAcceptedAt == null) {
      await _prefs.remove(_keyDisclaimer);
    } else {
      await _prefs.setString(
        _keyDisclaimer,
        snapshot.disclaimerAcceptedAt!.toIso8601String(),
      );
    }
    if (snapshot.profile == null) {
      await _prefs.remove(_keyProfileJson);
    } else {
      await _prefs.setString(
        _keyProfileJson,
        jsonEncode(snapshot.profile!.toJson()),
      );
    }
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_keySchema);
    await _prefs.remove(_keyComplete);
    await _prefs.remove(_keyCatheter);
    await _prefs.remove(_keyDisclaimer);
    await _prefs.remove(_keyProfileJson);
  }
}
```

- [ ] **Step 2: Gate notifier**

Create `onboarding_gate.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:kegel_master/features/onboarding/data/onboarding_persistence.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_profile.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_snapshot.dart';
import 'package:kegel_master/features/onboarding/domain/session_prescription.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';

class OnboardingGate extends ChangeNotifier {
  OnboardingGate(this._persistence);

  final OnboardingPersistence _persistence;

  OnboardingSnapshot _snapshot = OnboardingSnapshot.empty;

  OnboardingSnapshot get snapshot => _snapshot;

  Future<void> load() async {
    _snapshot = await _persistence.readSnapshot();
    notifyListeners();
  }

  Future<void> setDisclaimerAccepted(DateTime when) async {
    _snapshot = OnboardingSnapshot(
      onboardingComplete: _snapshot.onboardingComplete,
      catheterActive: _snapshot.catheterActive,
      disclaimerAcceptedAt: when,
      profile: _snapshot.profile,
    );
    await _persistence.writeSnapshot(_snapshot);
    notifyListeners();
  }

  Future<void> completeWithProfile(OnboardingProfile profile) async {
    final bool catheter = profile.hasCatheter;
    _snapshot = OnboardingSnapshot(
      onboardingComplete: true,
      catheterActive: catheter,
      disclaimerAcceptedAt: _snapshot.disclaimerAcceptedAt,
      profile: profile,
    );
    await _persistence.writeSnapshot(_snapshot);
    notifyListeners();
  }

  Future<void> resetAll() async {
    await _persistence.clear();
    _snapshot = OnboardingSnapshot.empty;
    notifyListeners();
  }

  SessionConfig? currentSessionConfigOrNull() {
    final OnboardingProfile? p = _snapshot.profile;
    if (!_snapshot.onboardingComplete || p == null) {
      return null;
    }
    return sessionPrescriptionFromProfile(p);
  }
}
```

- [ ] **Step 3: Analyze**

Run:

```text
dart analyze lib/features/onboarding/data/onboarding_persistence.dart lib/features/onboarding/application/onboarding_gate.dart
```

Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/features/onboarding/data/onboarding_persistence.dart lib/features/onboarding/application/onboarding_gate.dart
git commit -m "feat(onboarding): SharedPreferences persistence and OnboardingGate"
```

---

### Task 7: Router wiring, `main`, `OnboardingScope`

**Files:**

- Create: `e:\Projects\Repos\kegel_master\lib\features\onboarding\presentation\onboarding_scope.dart`
- Create: `e:\Projects\Repos\kegel_master\lib\features\onboarding\presentation\onboarding_flow_screen.dart` (minimal shell: `Scaffold` + `Text` placeholders per step; full copy in follow-up sub-steps within same task)
- Modify: `e:\Projects\Repos\kegel_master\lib\router\app_router.dart`
- Modify: `e:\Projects\Repos\kegel_master\lib\main.dart`
- Modify: `e:\Projects\Repos\kegel_master\lib\app.dart` (only if needed)

- [ ] **Step 1: `OnboardingScope`**

Create `onboarding_scope.dart`:

```dart
import 'package:flutter/widgets.dart';
import 'package:kegel_master/features/onboarding/application/onboarding_gate.dart';

class OnboardingScope extends InheritedNotifier<OnboardingGate> {
  const OnboardingScope({
    super.key,
    required OnboardingGate gate,
    required super.child,
  }) : super(notifier: gate);

  static OnboardingGate of(BuildContext context) {
    final OnboardingScope? scope =
        context.dependOnInheritedWidgetOfExactType<OnboardingScope>();
    assert(scope != null, 'OnboardingScope not found');
    return scope!.notifier!;
  }
}
```

- [ ] **Step 2: Minimal `OnboardingFlowScreen`**

Create `onboarding_flow_screen.dart` with a `StatefulWidget` that:

1. Step 0: disclaimer text + `FilledButton` **Accept** → `await OnboardingScope.of(context).setDisclaimerAccepted(DateTime.now())` → increment step.
2. Steps 1–5: use `ListView` + `RadioListTile` / `FilterChip` for selections; wire `OnboardingMutualExclusion` for multi-selects.
3. Step 6: summary `Text` of choices + **Confirm** → if `hasCatheter`, show step 7 safety full-screen text + **I understand** → `await gate.completeWithProfile(profile)` then `context.go('/home')` (redirect sends to `/learn` when catheter).
4. If no catheter: `completeWithProfile` then `context.go('/home')`.

Use concise placeholder strings for legal copy (spec allows placeholders).

- [ ] **Step 3: Replace `createAppRouter` with factory taking gate**

In `app_router.dart`:

1. Import `onboarding_flow_screen.dart`, `onboarding_gate.dart`, `onboarding_redirect.dart`, `onboarding_snapshot.dart`, `session_screen.dart` (already).
2. Replace `final GoRouter defaultAppRouter = createAppRouter();` with a pattern that builds router from gate (tests can pass a test gate + `SharedPreferences.setMockInitialValues`).

Example `createAppRouter` signature:

```dart
GoRouter createAppRouter({required OnboardingGate gate}) {
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: gate,
    redirect: (BuildContext context, GoRouterState state) {
      return resolveOnboardingRedirect(
        path: state.uri.path,
        snapshot: gate.snapshot,
      );
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/onboarding',
        builder: (BuildContext context, GoRouterState state) =>
            const OnboardingFlowScreen(),
      ),
      StatefulShellRoute.indexedStack(
        // ... existing branches ...
      ),
      GoRoute(
        path: '/session',
        builder: (BuildContext context, GoRouterState state) {
          final Object? extra = state.extra;
          final SessionConfig config = extra is SessionConfig
              ? extra
              : SessionConfig.defaults;
          return SessionScreen(config: config);
        },
      ),
    ],
    errorBuilder: // unchanged except use gate in redirect is automatic
  );
}
```

Remove the old standalone `defaultAppRouter` unless tests import it: provide `GoRouter? testRouter` factory in tests instead.

3. Remove redirect that only maps `/` → `/home` if it conflicts: global redirect now handles `/` → `/onboarding` when incomplete. When complete, `/` should still land in app: use `redirect` to return `/home` when `state.uri.path == '/' && snapshot.onboardingComplete` and not catheter blocked; when catheter and path `/`, return `/learn`.

Adjust `resolveOnboardingRedirect` in a small follow-up commit within this task if `'/'` needs explicit handling:

```dart
  if (path == '/') {
    if (!snapshot.onboardingComplete) {
      return '/onboarding';
    }
    if (snapshot.catheterActive) {
      return '/learn';
    }
    return '/home';
  }
```

Add this branch to `onboarding_redirect.dart` and extend `onboarding_redirect_test.dart` with:

```dart
  test('complete catheter maps slash to learn', () {
    final OnboardingSnapshot s = OnboardingSnapshot(
      onboardingComplete: true,
      catheterActive: true,
      profile: OnboardingProfile(
        gender: GenderIdentity.male,
        primaryGoal: PrimaryGoal.preventionMaintenance,
        ageBand: AgeBand.age18to34,
        symptoms: {Symptom.none},
        clinicalHistory: {ClinicalHistory.catheter},
      ),
    );
    expect(resolveOnboardingRedirect(path: '/', snapshot: s), '/learn');
  });
```

- [ ] **Step 4: `main.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:kegel_master/app.dart';
import 'package:kegel_master/features/onboarding/application/onboarding_gate.dart';
import 'package:kegel_master/features/onboarding/data/onboarding_persistence.dart';
import 'package:kegel_master/features/onboarding/presentation/onboarding_scope.dart';
import 'package:kegel_master/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final OnboardingPersistence persistence =
      SharedPreferencesOnboardingPersistence(prefs);
  final OnboardingGate gate = OnboardingGate(persistence);
  await gate.load();
  final GoRouter router = createAppRouter(gate: gate);
  runApp(
    OnboardingScope(
      gate: gate,
      child: KegelMasterApp(router: router),
    ),
  );
}
```

Add missing import for `go_router` if `GoRouter` type used (`import 'package:go_router/go_router.dart';`).

- [ ] **Step 5: `HomeScreen` uses gate for `SessionConfig`**

```dart
import 'package:kegel_master/features/onboarding/presentation/onboarding_scope.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';

// inside onPressed:
final SessionConfig? config =
    OnboardingScope.of(context).currentSessionConfigOrNull();
context.push('/session', extra: config ?? SessionConfig.defaults);
```

- [ ] **Step 6: Full `flutter test` + `dart analyze`**

Run:

```text
dart analyze
flutter test
```

Expected: analyze clean; all tests green.

- [ ] **Step 7: Commit**

```bash
git add lib/main.dart lib/router/app_router.dart lib/features/onboarding/presentation lib/features/home/presentation/home_screen.dart
git commit -m "feat(onboarding): GoRouter onboarding route, redirects, and Home session extra"
```

---

### Task 8: Learn banner, Settings reset, polish

**Files:**

- Modify: `e:\Projects\Repos\kegel_master\lib\features\learn\presentation\learn_screen.dart`
- Modify: `e:\Projects\Repos\kegel_master\lib\features\settings\presentation\settings_screen.dart`

- [ ] **Step 1: Learn catheter banner**

Use a static strip (no `ScaffoldMessenger`) so the warning always shows:

```dart
import 'package:flutter/material.dart';
import 'package:kegel_master/features/onboarding/presentation/onboarding_scope.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool catheter =
        OnboardingScope.of(context).snapshot.catheterActive;
    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (catheter)
            ColoredBox(
              color: Theme.of(context).colorScheme.errorContainer,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Pelvic floor exercises are suspended while you use a catheter. '
                  'Educational content only — follow your care team.',
                ),
              ),
            ),
          const Expanded(
            child: Center(
              child: Text('Guides and techniques — coming soon.'),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Settings reset**

Convert `SettingsScreen` to `StatefulWidget` or use `Builder` + `showDialog`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kegel_master/features/onboarding/presentation/onboarding_scope.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _onResetPressed(BuildContext context) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset onboarding?'),
          content: const Text(
            'This clears your saved answers and safety state. You will see the disclaimer and questions again.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
    if (ok == true && context.mounted) {
      await OnboardingScope.of(context).resetAll();
      if (context.mounted) {
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Reset onboarding'),
            subtitle: const Text('Clear profile and run setup again'),
            onTap: () => _onResetPressed(context),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Run `flutter test`**

Expected: all pass.

- [ ] **Step 4: Commit**

```bash
git add lib/features/learn/presentation/learn_screen.dart lib/features/settings/presentation/settings_screen.dart
git commit -m "feat(onboarding): Learn catheter notice and Settings reset flow"
```

---

### Task 9: Fix tests that imported `defaultAppRouter`

**Files:**

- Modify: any file under `e:\Projects\Repos\kegel_master\test\` that referenced `defaultAppRouter`

- [ ] **Step 1: Search references**

Run:

```text
rg "defaultAppRouter" test lib
```

- [ ] **Step 2: Update widget tests**

Provide `createAppRouter(gate: OnboardingGate(FakePersistence()))` where `FakePersistence` is a test double implementing `OnboardingPersistence` with in-memory fields, or use `SharedPreferences.setMockInitialValues` + real persistence.

Example in-memory fake:

```dart
class FakeOnboardingPersistence implements OnboardingPersistence {
  OnboardingSnapshot snapshot = OnboardingSnapshot.empty;

  @override
  Future<void> clear() async {
    snapshot = OnboardingSnapshot.empty;
  }

  @override
  Future<OnboardingSnapshot> readSnapshot() async => snapshot;

  @override
  Future<void> writeSnapshot(OnboardingSnapshot value) async {
    snapshot = value;
  }
}
```

- [ ] **Step 3: `flutter test`**

Expected: all pass.

- [ ] **Step 4: Commit**

```bash
git add test/
git commit -m "test: adapt router tests to injected OnboardingGate"
```

---

## Self-review (plan vs spec)

| Spec section | Plan coverage |
|--------------|---------------|
| GoRouter-first onboarding + redirect | Tasks 4, 7 |
| Disclaimer + Accept + timestamp | Task 6–7 (`setDisclaimerAccepted`) |
| All questions + None exclusivity | Tasks 2–3, 7 UI |
| Summary + edit | Task 7 UI (implement edit as `stepIndex = n` from summary buttons) |
| Catheter → safety screen then Learn-only | Task 7 flow + Task 8 Learn |
| Allow Learn + Settings under catheter | Task 4 tests + redirect |
| Block home/progress/session | Task 4 |
| Symptoms stored, no v1 prescription use | Task 5 tests + prescription code |
| `catheterActive` persisted | Task 6 |
| Reset clears + `/onboarding` | Task 6–8 |
| `fromProfile` age/goal/clinical (not catheter for numbers) | Task 5 (catheter not used in math; user never reaches session when catheter) |
| Home pushes session with prescription | Task 7 |
| Unit tests: redirect, exclusivity, prescription | Tasks 3–5; Task 9 for integration |

**Placeholder scan:** No `TBD` / vague steps; numeric tuning lives in `session_prescription.dart` with explicit deltas.

**Type consistency:** `OnboardingGate`, `OnboardingSnapshot`, `resolveOnboardingRedirect`, `sessionPrescriptionFromProfile` names match across tasks.

**Gap closed:** Explicit `/` handling added in Task 7 redirect extension.

---

Plan complete and saved to `docs/superpowers/plans/2026-04-29-onboarding-flow.md`. Two execution options:

**1. Subagent-Driven (recommended)** — Dispatch a fresh subagent per task, review between tasks, fast iteration.

**2. Inline Execution** — Execute tasks in this session using executing-plans, batch execution with checkpoints.

Which approach?

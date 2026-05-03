# Clinical preset session config Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace incremental `sessionPrescriptionFromProfile` tuning with fixed clinical presets from [2026-05-02-clinical-preset-session-config-design.md](../specs/2026-05-02-clinical-preset-session-config-design.md): enum catalog + `presetForProfile`, align `SessionConfig.defaults` with Foundational/Beginner, and update tests.

**Architecture:** New domain file `kegel_clinical_preset.dart` holds `KegelClinicalPreset` enum, a `SessionConfig config` getter per value (const `SessionConfig` literals matching the spec table for **six v1-active** presets—**Postpartum Initial 0–48h** is documented in the spec only, not an enum member until onboarding adds timing). Pure function `KegelClinicalPreset presetForProfile(OnboardingProfile p)` encodes the priority rules (goal-first structure equivalent to the spec’s ordered table). `session_prescription.dart` becomes a one-line delegator so `effective_session_config.dart` and `onboarding_gate.dart` keep stable imports.

**Tech Stack:** Flutter 3.x, Dart ^3.10, existing `SessionConfig` / `OnboardingProfile` types.

---

## File map (create / modify)

| Path | Responsibility |
|------|----------------|
| `lib/features/onboarding/domain/kegel_clinical_preset.dart` | **Create:** enum `KegelClinicalPreset` (six values), `SessionConfig get config`, `KegelClinicalPreset presetForProfile(OnboardingProfile p)`. |
| `lib/features/onboarding/domain/session_prescription.dart` | **Modify:** remove incremental logic; `sessionPrescriptionFromProfile` → `presetForProfile(profile).config`. |
| `lib/features/session/domain/session_config.dart` | **Modify:** `SessionConfig.defaults` → `(3, 3, 60, 10, 3)` per spec. |
| `test/features/onboarding/domain/kegel_clinical_preset_test.dart` | **Create:** table-driven preset resolution + overlap cases from spec matrix. |
| `test/features/onboarding/domain/session_prescription_test.dart` | **Modify:** symptoms-invariant test + thin-wrapper parity (or slim file delegating to preset tests). |
| `test/effective_session_config_test.dart` | **Verify:** still passes once defaults and prescription change (update test names/comments only if misleading). |

---

### Task 1: `KegelClinicalPreset` + `presetForProfile` (TDD)

**Files:**
- Create: `lib/features/onboarding/domain/kegel_clinical_preset.dart`
- Create: `test/features/onboarding/domain/kegel_clinical_preset_test.dart`

**Enum members (v1 — six presets):**

| Enum value (suggested name) | Maps to spec row |
|----------------------------|------------------|
| `foundationalBeginner` | Foundational / Beginner |
| `advancedEndurance` | Advanced / Endurance goal |
| `postpartumRestorative` | Postpartum (Restorative 2–8 wks) |
| `postProstatectomyRecovery` | Post–prostatectomy (Recovery) |
| `geriatricSarcopenia` | Geriatric (55+) / Sarcopenia |
| `sexualPerformance` | Sexual performance (male / female) |

- [ ] **Step 1: Write failing tests** — create `test/features/onboarding/domain/kegel_clinical_preset_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kegel_master/features/onboarding/domain/kegel_clinical_preset.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_profile.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';

OnboardingProfile _p({
  required PrimaryGoal goal,
  AgeBand age = AgeBand.age18to34,
  Set<Symptom> symptoms = const {Symptom.none},
  Set<ClinicalHistory> clinical = const {ClinicalHistory.none},
  GenderIdentity gender = GenderIdentity.female,
}) {
  return OnboardingProfile(
    gender: gender,
    primaryGoal: goal,
    ageBand: age,
    symptoms: symptoms,
    clinicalHistory: clinical,
  );
}

void _expectConfig(SessionConfig c, SessionConfig expected) {
  expect(c.squeezeSeconds, expected.squeezeSeconds);
  expect(c.relaxSeconds, expected.relaxSeconds);
  expect(c.bufferBetweenSetsSeconds, expected.bufferBetweenSetsSeconds);
  expect(c.repsPerSet, expected.repsPerSet);
  expect(c.targetSets, expected.targetSets);
}

void main() {
  final SessionConfig foundational = SessionConfig(
    squeezeSeconds: 3,
    relaxSeconds: 3,
    bufferBetweenSetsSeconds: 60,
    repsPerSet: 10,
    targetSets: 3,
  );
  final SessionConfig advanced = SessionConfig(
    squeezeSeconds: 10,
    relaxSeconds: 10,
    bufferBetweenSetsSeconds: 60,
    repsPerSet: 10,
    targetSets: 3,
  );
  final SessionConfig postpartum = SessionConfig(
    squeezeSeconds: 5,
    relaxSeconds: 10,
    bufferBetweenSetsSeconds: 90,
    repsPerSet: 10,
    targetSets: 3,
  );
  final SessionConfig prostate = SessionConfig(
    squeezeSeconds: 10,
    relaxSeconds: 10,
    bufferBetweenSetsSeconds: 60,
    repsPerSet: 10,
    targetSets: 4,
  );
  final SessionConfig geriatric = SessionConfig(
    squeezeSeconds: 3,
    relaxSeconds: 5,
    bufferBetweenSetsSeconds: 120,
    repsPerSet: 10,
    targetSets: 3,
  );
  final SessionConfig sexual = SessionConfig(
    squeezeSeconds: 10,
    relaxSeconds: 10,
    bufferBetweenSetsSeconds: 45,
    repsPerSet: 15,
    targetSets: 3,
  );

  test('preset config getters match clinical table', () {
    _expectConfig(
      KegelClinicalPreset.foundationalBeginner.config,
      foundational,
    );
    _expectConfig(KegelClinicalPreset.advancedEndurance.config, advanced);
    _expectConfig(
      KegelClinicalPreset.postpartumRestorative.config,
      postpartum,
    );
    _expectConfig(
      KegelClinicalPreset.postProstatectomyRecovery.config,
      prostate,
    );
    _expectConfig(KegelClinicalPreset.geriatricSarcopenia.config, geriatric);
    _expectConfig(KegelClinicalPreset.sexualPerformance.config, sexual);
  });

  test('post-surgical prostate goal → postProstatectomyRecovery', () {
    expect(
      presetForProfile(
        _p(goal: PrimaryGoal.postSurgicalProstateRecovery),
      ),
      KegelClinicalPreset.postProstatectomyRecovery,
    );
  });

  test('postpartum recovery → postpartumRestorative', () {
    expect(
      presetForProfile(_p(goal: PrimaryGoal.postpartumRecovery)),
      KegelClinicalPreset.postpartumRestorative,
    );
  });

  test('postpartum + 55+ still postpartum (priority over geriatric)', () {
    expect(
      presetForProfile(
        _p(goal: PrimaryGoal.postpartumRecovery, age: AgeBand.age55plus),
      ),
      KegelClinicalPreset.postpartumRestorative,
    );
  });

  test('sexual performance → sexualPerformance including 55+', () {
    expect(
      presetForProfile(
        _p(goal: PrimaryGoal.sexualPerformanceEnhancement),
      ),
      KegelClinicalPreset.sexualPerformance,
    );
    expect(
      presetForProfile(
        _p(
          goal: PrimaryGoal.sexualPerformanceEnhancement,
          age: AgeBand.age55plus,
        ),
      ),
      KegelClinicalPreset.sexualPerformance,
    );
  });

  test('55+ prevention → geriatric', () {
    expect(
      presetForProfile(
        _p(
          goal: PrimaryGoal.preventionMaintenance,
          age: AgeBand.age55plus,
        ),
      ),
      KegelClinicalPreset.geriatricSarcopenia,
    );
  });

  test('55+ incontinence → geriatric', () {
    expect(
      presetForProfile(
        _p(
          goal: PrimaryGoal.incontinenceManagement,
          age: AgeBand.age55plus,
        ),
      ),
      KegelClinicalPreset.geriatricSarcopenia,
    );
  });

  test('18-34 prevention → advanced', () {
    expect(
      presetForProfile(
        _p(goal: PrimaryGoal.preventionMaintenance, age: AgeBand.age18to34),
      ),
      KegelClinicalPreset.advancedEndurance,
    );
  });

  test('35-54 prevention → advanced', () {
    expect(
      presetForProfile(
        _p(goal: PrimaryGoal.preventionMaintenance, age: AgeBand.age35to54),
      ),
      KegelClinicalPreset.advancedEndurance,
    );
  });

  test('18-34 incontinence → foundational', () {
    expect(
      presetForProfile(
        _p(goal: PrimaryGoal.incontinenceManagement, age: AgeBand.age18to34),
      ),
      KegelClinicalPreset.foundationalBeginner,
    );
  });

  test('symptoms do not change preset', () {
    final OnboardingProfile a = _p(
      goal: PrimaryGoal.preventionMaintenance,
      symptoms: {Symptom.none},
    );
    final OnboardingProfile b = _p(
      goal: PrimaryGoal.preventionMaintenance,
      symptoms: {Symptom.chronicPelvicPain, Symptom.suddenUrges},
    );
    expect(presetForProfile(a), presetForProfile(b));
  });
}
```

- [ ] **Step 2: Run test (expect FAIL)**  

Run: `flutter test test/features/onboarding/domain/kegel_clinical_preset_test.dart`  
**Expected:** compile error / undefined `KegelClinicalPreset`, `presetForProfile`.

- [ ] **Step 3: Implement** — create `lib/features/onboarding/domain/kegel_clinical_preset.dart`:

```dart
import 'package:kegel_master/features/onboarding/domain/onboarding_profile.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';

enum KegelClinicalPreset {
  foundationalBeginner,
  advancedEndurance,
  postpartumRestorative,
  postProstatectomyRecovery,
  geriatricSarcopenia,
  sexualPerformance,
}

extension KegelClinicalPresetConfig on KegelClinicalPreset {
  SessionConfig get config => switch (this) {
        KegelClinicalPreset.foundationalBeginner => SessionConfig(
            squeezeSeconds: 3,
            relaxSeconds: 3,
            bufferBetweenSetsSeconds: 60,
            repsPerSet: 10,
            targetSets: 3,
          ),
        KegelClinicalPreset.advancedEndurance => SessionConfig(
            squeezeSeconds: 10,
            relaxSeconds: 10,
            bufferBetweenSetsSeconds: 60,
            repsPerSet: 10,
            targetSets: 3,
          ),
        KegelClinicalPreset.postpartumRestorative => SessionConfig(
            squeezeSeconds: 5,
            relaxSeconds: 10,
            bufferBetweenSetsSeconds: 90,
            repsPerSet: 10,
            targetSets: 3,
          ),
        KegelClinicalPreset.postProstatectomyRecovery => SessionConfig(
            squeezeSeconds: 10,
            relaxSeconds: 10,
            bufferBetweenSetsSeconds: 60,
            repsPerSet: 10,
            targetSets: 4,
          ),
        KegelClinicalPreset.geriatricSarcopenia => SessionConfig(
            squeezeSeconds: 3,
            relaxSeconds: 5,
            bufferBetweenSetsSeconds: 120,
            repsPerSet: 10,
            targetSets: 3,
          ),
        KegelClinicalPreset.sexualPerformance => SessionConfig(
            squeezeSeconds: 10,
            relaxSeconds: 10,
            bufferBetweenSetsSeconds: 45,
            repsPerSet: 15,
            targetSets: 3,
          ),
      };
}

KegelClinicalPreset presetForProfile(OnboardingProfile p) {
  switch (p.primaryGoal) {
    case PrimaryGoal.postSurgicalProstateRecovery:
      return KegelClinicalPreset.postProstatectomyRecovery;
    case PrimaryGoal.postpartumRecovery:
      return KegelClinicalPreset.postpartumRestorative;
    case PrimaryGoal.sexualPerformanceEnhancement:
      return KegelClinicalPreset.sexualPerformance;
    case PrimaryGoal.preventionMaintenance:
      if (p.ageBand == AgeBand.age55plus) {
        return KegelClinicalPreset.geriatricSarcopenia;
      }
      return KegelClinicalPreset.advancedEndurance;
    case PrimaryGoal.incontinenceManagement:
      if (p.ageBand == AgeBand.age55plus) {
        return KegelClinicalPreset.geriatricSarcopenia;
      }
      return KegelClinicalPreset.foundationalBeginner;
  }
}
```

- [ ] **Step 4: Run test (expect PASS)**  

Run: `flutter test test/features/onboarding/domain/kegel_clinical_preset_test.dart`  
**Expected:** all tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/features/onboarding/domain/kegel_clinical_preset.dart test/features/onboarding/domain/kegel_clinical_preset_test.dart
git commit -m "feat(onboarding): add KegelClinicalPreset catalog and presetForProfile"
```

---

### Task 2: Wire `sessionPrescriptionFromProfile` to preset

**Files:**
- Modify: `lib/features/onboarding/domain/session_prescription.dart`

- [ ] **Step 1: Replace file body** with:

```dart
import 'package:kegel_master/features/onboarding/domain/kegel_clinical_preset.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_profile.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';

SessionConfig sessionPrescriptionFromProfile(OnboardingProfile profile) {
  return presetForProfile(profile).config;
}
```

- [ ] **Step 2: Run preset + prescription tests**  

Run: `flutter test test/features/onboarding/domain/kegel_clinical_preset_test.dart test/features/onboarding/domain/session_prescription_test.dart`  
**Expected:** `session_prescription_test.dart` may **FAIL** until Task 3–4 update old expectations.

- [ ] **Step 3: Commit** (after Task 4 tests green, or commit here if you batch Task 2–4 in one commit—prefer **one commit after all tests green** for Tasks 2–4 together):

```bash
git add lib/features/onboarding/domain/session_prescription.dart
git commit -m "refactor(onboarding): derive prescription from clinical preset"
```

---

### Task 3: Align `SessionConfig.defaults`

**Files:**
- Modify: `lib/features/session/domain/session_config.dart` (only the `defaults` const)

- [ ] **Step 1: Set** `SessionConfig.defaults` to Foundational/Beginner:

```dart
  static const SessionConfig defaults = SessionConfig._(
    squeezeSeconds: 3,
    relaxSeconds: 3,
    bufferBetweenSetsSeconds: 60,
    repsPerSet: 10,
    targetSets: 3,
  );
```

- [ ] **Step 2: Run full test suite**  

Run: `flutter test`  
**Expected:** any test that assumed old defaults `(3,3,4,5,3)` may fail—fix in Task 4.

- [ ] **Step 3: Commit** (can merge with Task 4 commit)

```bash
git add lib/features/session/domain/session_config.dart
git commit -m "fix(session): align SessionConfig.defaults with foundational preset"
```

---

### Task 4: Update `session_prescription_test` and verify `effective_session_config`

**Files:**
- Modify: `test/features/onboarding/domain/session_prescription_test.dart`
- Read-only verify: `test/effective_session_config_test.dart`

- [ ] **Step 1: Replace** `session_prescription_test.dart` with tests that match the new behavior (keep **symptoms invariant**; drop obsolete “relax > defaults” assertions). Example content:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kegel_master/features/onboarding/domain/kegel_clinical_preset.dart';
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
  test('sessionPrescriptionFromProfile matches presetForProfile.config', () {
    final OnboardingProfile p = OnboardingProfile(
      gender: GenderIdentity.male,
      primaryGoal: PrimaryGoal.incontinenceManagement,
      ageBand: AgeBand.age35to54,
      symptoms: {Symptom.none},
      clinicalHistory: {ClinicalHistory.none},
    );
    expect(
      sessionPrescriptionFromProfile(p),
      presetForProfile(p).config,
    );
  });

  test('symptoms do not change prescription', () {
    final OnboardingProfile a = _base(symptoms: {Symptom.none});
    final OnboardingProfile b = _base(
      symptoms: {Symptom.chronicPelvicPain, Symptom.suddenUrges},
    );
    expect(
      sessionPrescriptionFromProfile(a),
      sessionPrescriptionFromProfile(b),
    );
  });

  test('prevention 18-34 matches advanced endurance config', () {
    final SessionConfig c = sessionPrescriptionFromProfile(
      OnboardingProfile(
        gender: GenderIdentity.nonBinary,
        primaryGoal: PrimaryGoal.preventionMaintenance,
        ageBand: AgeBand.age18to34,
        symptoms: {Symptom.none},
        clinicalHistory: {ClinicalHistory.none},
      ),
    );
    expect(c, KegelClinicalPreset.advancedEndurance.config);
  });
}
```

- [ ] **Step 2: Run** `flutter test`  
**Expected:** all tests pass (including `test/effective_session_config_test.dart`—`minimalProfile` is prevention + 18–34 → advanced; defaults tests still valid because `SessionConfig.defaults` now equals foundational).

- [ ] **Step 3: Commit**

```bash
git add test/features/onboarding/domain/session_prescription_test.dart
git commit -m "test(onboarding): align session prescription tests with presets"
```

---

## Plan self-review

| Spec section | Task covering it |
|--------------|------------------|
| Personalized table (six active presets) | Task 1 `config` switch |
| v1 no Postpartum Initial in mapper | Task 1 (no enum member) |
| Overlap / priority rules | Task 1 `presetForProfile` + tests |
| `SessionConfig.defaults` = Foundational | Task 3 |
| `sessionPrescriptionFromProfile` thin wrapper | Task 2 |
| Effective config unchanged | No code change; Task 4 verifies tests |
| Symptoms not inputs | Task 1 + 4 tests |

**Placeholder scan:** None intentional.

**Type consistency:** `presetForProfile` and `KegelClinicalPreset` names match Tasks 1–2; `SessionConfig` factory validation unchanged.

---

## Execution handoff

**Plan complete and saved to** `docs/superpowers/plans/2026-05-02-clinical-preset-session-config.md`.

**Two execution options:**

1. **Subagent-Driven (recommended)** — Dispatch a fresh subagent per task, review between tasks, fast iteration. **REQUIRED SUB-SKILL:** `superpowers:subagent-driven-development`.

2. **Inline Execution** — Run tasks in this session with checkpoints. **REQUIRED SUB-SKILL:** `superpowers:executing-plans`.

**Which approach do you want?**

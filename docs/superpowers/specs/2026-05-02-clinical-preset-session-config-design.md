# Clinical preset session plans — design

**Date:** 2026-05-02  
**Status:** Draft (awaiting product review).

## Summary

Replace incremental `SessionConfig` tuning from `SessionConfig.defaults` with **exactly one fixed clinical preset** per completed onboarding profile. Numbers live in a **single catalog** (enum + const `SessionConfig` values). **`resolveEffectiveSessionConfig`** keeps the same precedence: **user mirror** overrides preset; else **preset from profile**; else **`SessionConfig.defaults`**.

## Goals

- One **`SessionConfig`** per user when onboarding is complete and no mirror is set—chosen from an approved **personalized plan** table.
- **Deterministic** mapping from **`OnboardingProfile`** to a preset; **documented overlap resolution** when several rows could apply.
- **v1:** Do **not** resolve to **Postpartum (Initial 0–48h)**; defer until onboarding captures timing since delivery. Postpartum users use **Postpartum (Restorative 2–8 wks)**.

## Non-goals

- Symptom-driven prescription (unchanged: symptoms stored for later; see [2026-04-29-onboarding-flow-design.md](./2026-04-29-onboarding-flow-design.md)).
- JSON/asset-driven preset tables (only seven rows; consts in Dart are sufficient until editorial workflow demands otherwise).
- Clinical sign-off on copy or numbers in this document (values are **tunable constants**).

## Personalized plans (clinical preset table)

Each row maps 1:1 to **`SessionConfig`** fields: `squeezeSeconds`, `relaxSeconds`, `bufferBetweenSetsSeconds`, `repsPerSet`, `targetSets`.

| User profile (preset) | squeeze | relax | buffer (s) | reps / set | sets |
|------------------------|--------:|------:|-----------:|-----------:|-----:|
| Foundational / Beginner | 3 | 3 | 60 | 10 | 3 |
| Advanced / Endurance goal | 10 | 10 | 60 | 10 | 3 |
| Postpartum (Initial 0–48 hr) | 1 | 10 | 120 | 10 | 3 |
| Postpartum (Restorative 2–8 wks) | 5 | 10 | 90 | 10 | 3 |
| Post–prostatectomy (Recovery) | 10 | 10 | 60 | 10 | 4 |
| Geriatric (55+) / Sarcopenia | 3 | 5 | 120 | 10 | 3 |
| Sexual performance (male / female) | 10 | 10 | 45 | 15 | 3 |

### v1 scope for postpartum initial

- **Mapper must not** emit **Postpartum (Initial 0–48 hr)** until onboarding adds a **time-since-delivery** (or equivalent) signal.
- Until then, any profile that would eventually use the initial row uses **Postpartum (Restorative 2–8 wks)** instead.

## `SessionConfig.defaults`

Align **`SessionConfig.defaults`** with **Foundational / Beginner** `(3, 3, 60, 10, 3)` so router and test fallbacks match the gentle general row and are consistent with the catalog.

## Overlap resolution

Onboarding collects a **single** `PrimaryGoal` and other fields (`AgeBand`, `ClinicalHistory`, etc.). Presets are chosen by **evaluating rules in strict priority order**; the **first matching rule** wins.

**Catheter:** Not a preset. If **`catheterActive`** / Learn-only gate applies per [2026-04-29-onboarding-flow-design.md](./2026-04-29-onboarding-flow-design.md), the user does not start a normal session; preset choice is irrelevant until the gate is cleared.

### Priority list (highest → lowest)

| Order | Condition (all on `OnboardingProfile`) | Preset |
|------:|------------------------------------------|--------|
| 1 | `primaryGoal == postSurgicalProstateRecovery` | Post–prostatectomy (Recovery) |
| 2 | `primaryGoal == postpartumRecovery` | Postpartum (Restorative 2–8 wks) — v1; Initial row deferred |
| 3 | `primaryGoal == sexualPerformanceEnhancement` | Sexual performance (male / female) |
| 4 | `ageBand == age55plus` | Geriatric (55+) / Sarcopenia |
| 5 | `primaryGoal == preventionMaintenance` **and** `ageBand` is `age18to34` or `age35to54` | Advanced / Endurance goal |
| 6 | `primaryGoal == incontinenceManagement` | Foundational / Beginner |
| 7 | (fallback) Any profile not matched above | Foundational / Beginner |

### Rationale (short)

- **Prostate** and **postpartum** goals are the most **context-specific** clinical tracks; they win over age- or performance-tuned rows.
- **Sexual performance** goal is explicit; it wins over **geriatric** so a 55+ user who chose sexual enhancement is not silently moved to the sarcopenia-timed row without changing goal (if product later prefers geriatric when 55+, that becomes a one-line priority swap between rows 3 and 4).
- **55+** with **prevention** or **incontinence** maps to **Geriatric** before the “younger adult” **Advanced** row.
- **Prevention** for **18–54** maps to **Advanced / Endurance**.
- **Incontinence** maps to **Foundational** for conservative volume unless rule 4 already selected **Geriatric** (55+ incontinence → Geriatric).

### Combination matrix (reference)

Single `primaryGoal` means many combinations are impossible. For remaining mixes, the **ordered rules** above are authoritative; this matrix is a human-readable cross-check.

| Primary goal | Age 18–34 / 35–54 | Age 55+ |
|--------------|-------------------|---------|
| Post–surgical prostate | Post–prostatectomy | Post–prostatectomy |
| Postpartum recovery | Postpartum restorative | Postpartum restorative |
| Sexual performance | Sexual performance | Sexual performance |
| Prevention / maintenance | Advanced | Geriatric |
| Incontinence | Foundational | Geriatric |

`ClinicalHistory` entries (e.g. `birthWithin8Weeks`, `recentProstateSurgery`) refine **copy** and future rules; **v1 preset choice** follows **`primaryGoal` and `ageBand`** as in the priority table. Optional future tightening: require `recentProstateSurgery` for row 1 or `birthWithin8Weeks` for row 2—only if product wants stricter alignment with self-reported history.

## Architecture

- **`KegelClinicalPreset`** (name TBD): enum (or sealed type) with one variant per **active v1** preset; each exposes **`SessionConfig config`**.
- **`KegelClinicalPreset presetForProfile(OnboardingProfile p)`** (pure): implements the overlap table.
- **`SessionConfig sessionPrescriptionFromProfile(OnboardingProfile p)`** becomes a thin wrapper: `return presetForProfile(p).config;` or is **replaced** by callers using `presetForProfile` directly—**no** incremental `copyWith` from old defaults.
- **Persistence:** Continue storing **`OnboardingProfile`** as today; recomputing preset on read is acceptable. Optional later: persist **`presetId`** for analytics/UI labels.

## Effective config

Unchanged from [2026-05-01-app-storage-design.md](./2026-05-01-app-storage-design.md):

1. If **`sessionConfigMirror`** is non-null → use mirror.
2. Else if onboarding complete and profile present → **`presetForProfile(profile).config`**.
3. Else → **`SessionConfig.defaults`**.

## Testing

- Table-driven tests: each **active v1** preset has at least one profile that resolves to it.
- Tests for **55+** × **prevention**, **55+** × **incontinence**, **55+** × **sexual**, and **postpartum** × **55+** to lock overlap behavior.
- JSON roundtrip tests for `SessionConfig` unchanged; update expectations if defaults change.

## Migration / product note

Users who completed onboarding under the **old incremental prescription** may see **different timings** after upgrade. Call out in changelog if needed.

## Related documents

- [2026-04-29-onboarding-flow-design.md](./2026-04-29-onboarding-flow-design.md) — questionnaire, catheter gate, symptoms.
- [2026-05-01-app-storage-design.md](./2026-05-01-app-storage-design.md) — mirror and effective `SessionConfig`.
- [2026-04-26-home-session-screens-design.md](./2026-04-26-home-session-screens-design.md) — session phase semantics.

# Learn tab — vertical slices (local tasks)

**Source spec:** [../specs/2026-05-26-learn-tab-spec.md](../specs/2026-05-26-learn-tab-spec.md)  
**Glossary:** [../../../CONTEXT.md](../../../CONTEXT.md)  
**Type:** All slices below are AFK (implementable without design gate unless you add one).

---

## Task 1: Learn shell, Learn shell disclaimer, and foundation facts

**Blocked by:** None — can start immediately

### What to build

Replace the Learn placeholder with a scrollable **Learn** hub that shows a persistent **Learn shell disclaimer** and the first section of the **Canonical Learn order**: foundation facts. Ship copy through **Learn localization (MVP)** (ARB keys, no raw user-visible literals). Store structured foundation content in a **Learn release bundle** (e.g. assets or versioned Dart/JSON models) suitable for v1.

Preserve existing **Active catheter** educational banner behavior on this surface; integrate it with the new layout.

### Acceptance criteria

- [ ] `LearnScreen` (or equivalent) shows disclaimer + scroll body; foundation section is real content, not a single “coming soon” for that block.
- [ ] All new user-visible strings go through generated l10n.
- [ ] Foundation cards respect **Learn educational framing** (qualitative copy; no false-precision prevalence claims).
- [ ] Widget and/or unit coverage proves disclaimer + at least one foundation item render with a non-default profile wired through the same scope pattern the app uses (e.g. `pumpWidget` + `OnboardingScope`).

---

## Task 2: Profile-derived Learn signals

**Blocked by:** None — can start immediately (coordinate file overlap with Task 1 if both touch the same providers/widgets)

### What to build

From **`OnboardingProfile`** (symptoms, clinical history, gender, primary goal — existing enums), derive and expose: `hasHypertonicityRiskSymptom` (`chronicPelvicPain` or `difficultyStartingStream`), `hasActiveCatheter`, `trainingPivotActive` **without** override flag yet (override absent = pivot follows symptoms only), default **Anatomy track** suggestion from **Gender identity**, and **Troubleshooter default tab** index per CONTEXT (**Training pivot** wins when applicable). Pure Dart + tests first; wire into the app’s existing profile scope pattern so Learn and settings can consume later.

### Acceptance criteria

- [ ] Documented mapping matches spec table (pivot trigger, tab precedence).
- [ ] Unit tests cover representative combinations (urge-only, pivot-only, both, neither, non-binary gender for anatomy default).
- [ ] Signals reachable from the same architectural path Learn will use (e.g. scope / provider), without hard-coding UI in this task.

---

## Task 3: Anatomy track how-to

**Blocked by:** Task 1

### What to build

Add the **Canonical Learn order** “how-to” block: **Anatomy track** selection with UI copy that respects anatomy vs **Gender identity** rules. Default track from identity where the spec allows; explicit chooser for `nonBinary` and overrides. Apply **Learn privacy expansion**: tactile / insertion guidance only behind an explicit expand control.

### Acceptance criteria

- [ ] Section appears in fixed order after foundation.
- [ ] No “female/male guide” framing; vocabulary matches CONTEXT.
- [ ] Non-binary and override paths are usable and not mislabeled.
- [ ] Privacy expansion behavior covered by widget test or clear manual QA notes in PR.

---

## Task 4: Dos and don’ts

**Blocked by:** Task 3

### What to build

Dos/don’ts section with clear affordances (e.g. check/cross), bundle-backed copy, **Learn voice** (plain first; blunt warnings).

### Acceptance criteria

- [ ] Section follows foundation + how-to in **Canonical Learn order**.
- [ ] Strings via l10n; content from **Learn release bundle**.
- [ ] At least smoke-level test or golden for layout regression optional but preferred if repo already uses goldens.

---

## Task 5: Learn guided movement (MVP)

**Blocked by:** Task 4

### What to build

**Learn guided movement (MVP)**: per-drill accordions or equivalent, numbered steps, optional still images only — no bespoke interactive animation requirement for v1.

### Acceptance criteria

- [ ] At least one drill end-to-end with steps + optional asset path wired.
- [ ] No requirement for Rive/Lottie in acceptance path.
- [ ] Copy and structure live in the bundle + l10n pattern established in Task 1.

---

## Task 6: Learn troubleshooter

**Blocked by:** Task 5, Task 2

### What to build

Tabbed **Learn troubleshooter** (urge, stress, hypertonicity-style). **Troubleshooter default tab** from Task 2 signals; all tabs always reachable.

### Acceptance criteria

- [ ] Three sibling tabs with content from bundle.
- [ ] Default tab matches matrix from spec + CONTEXT for symptom + pivot combinations.
- [ ] Widget or unit tests for default index given mocked signals.

---

## Task 7: Learn suggested link

**Blocked by:** Task 6, Task 2

### What to build

Optional **Learn suggested link** near the top of the Learn scroll that deep-links into the best-matching subsection using **Primary goal**, **Symptom**, and **Training pivot** — without reordering **Canonical Learn order**.

### Acceptance criteria

- [ ] Link targets anchor or navigation within Learn only (no fake reordering of sections).
- [ ] Behavior verified for at least two distinct profile shapes (e.g. different primary goal / symptom).
- [ ] When no strong signal, omit the callout or neutral copy per CONTEXT / spec hub row (no misleading or dead deep link).

---

## Task 8: Training pivot override

**Blocked by:** Task 2

### What to build

Persisted **Training pivot override**: settings (or equivalent) flow with explicit acknowledgment; update `trainingPivotActive` semantics so override relaxes pivot until symptoms/flow change per CONTEXT. Consumers (Learn suggested link, troubleshooter, training surfaces) should read the updated signal — integrate in this task for any code already reading Task 2’s API.

### Acceptance criteria

- [ ] Persistence survives app restart (same mechanism as other user prefs in app).
- [ ] Acknowledgment is explicit (not a hidden toggle).
- [ ] Unit tests for pivot active / inactive with override on/off and symptom sets.

---

## Task 9: Training surfaces — pivot and catheter precedence

**Blocked by:** Task 2, Task 8

### What to build

On **training-oriented** surfaces (outside Learn tab): when `trainingPivotActive && !hasActiveCatheter`, apply pivot behavior (de-emphasize aggressive strengthening) per spec; when **Active catheter**, a single dominant safety story takes precedence over pivot messaging on those surfaces. Learn remains education-only.

### Acceptance criteria

- [ ] Document which routes/screens count as “training-oriented” in the PR or a short ADR note if none exists.
- [ ] No conflicting stacked CTAs where sessions are already suspended for catheter.
- [ ] Tests or integration coverage where the app already tests navigation/shell behavior.

---

## Dependency summary

```text
1 (shell + foundation) ──► 3 (anatomy) ──► 4 (dos) ──► 5 (movement) ──► 6 (troubleshooter) ──► 7 (suggested link)
2 (signals) ───────────────────────────────► 6, 7, 8
2 + 8 ─────────────────────────────────────► 9
```

Task 2 can run in parallel with Task 1; merge order may require small integration passes before Task 6–9.

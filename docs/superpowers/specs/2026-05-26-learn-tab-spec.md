# Learn tab — content framework and product rules

**Date:** 2026-05-26  
**Status:** Approved (conversation).  
**Domain glossary:** [CONTEXT.md](../../../CONTEXT.md) (authoritative terms: **Anatomy track**, **Training pivot**, **Learn release bundle**, etc.).

## Goals

- Replace the Learn placeholder with the **Canonical Learn order**: foundation facts → anatomy-track how-to → dos/don’ts → **Learn guided movement (MVP)** → **Learn troubleshooter**.
- Respect **Learn educational framing**, **Learn shell disclaimer**, **Learn voice**, and **Learn privacy expansion** in all copy and layout.
- Wire **profile-driven** behavior: default **Anatomy track**, **Troubleshooter default tab**, **Learn suggested link**, **Training pivot** (and override), and **Active catheter** precedence as defined in CONTEXT.

## Non-goals (v1)

- Remote CMS, OTA copy, or in-app **citation / reference** drawers (**Learn release bundle** only).
- Bespoke interactive motion for integration drills (**Learn guided movement (MVP)** = steps + optional stills).
- Reordering Learn sections per user (**Canonical Learn order**); personalization is limited to **Learn suggested link**, segment defaults, and troubleshooter default tab only.

## Product rules

| Topic | Decision |
|--------|-----------|
| Disclaimer | One persistent **Learn shell disclaimer** on the Learn shell; qualitative stats only (**Learn educational framing**). |
| Anatomy vs identity | UI uses **Anatomy track** language; **Gender identity** may set a default track only; non-binary and overrides must not be mislabeled. |
| Touch / insertion steps | **Learn privacy expansion**: optional tactile blocks behind explicit expand, not inline by default. |
| Troubleshooter | Three sibling tabs in fixed order: urge (index 0) → stress → hypertonicity-style; **Troubleshooter default tab** from **Symptom** + **Training pivot** (**Training pivot** wins); all tabs always reachable. When nothing maps, default to urge with neutral copy (see CONTEXT). |
| Training pivot trigger | **Hypertonicity-risk symptom**: `chronicPelvicPain` **or** `difficultyStartingStream` in onboarding `Symptom` set. |
| Pivot exit | **Training pivot override** (acknowledged settings path) **or** remove hypertonicity-risk symptoms from profile. |
| Active catheter | On training-oriented surfaces, **Active catheter** messaging **takes precedence** over **Training pivot**; Learn remains education-only (existing catheter banner pattern can extend). |
| Copy pipeline | **Learn localization (MVP)**: English-only shipped strings via normal Flutter l10n; content from **Learn release bundle**. |
| Hub layout | **Learn suggested link** near top may deep-link using **Primary goal**, **Symptom**, **Training pivot**; section order unchanged. Weak or ambiguous mapping: omit the callout or neutral copy without a misleading or broken deep link. |

## Screen map (illustrative)

- **`LearnScreen`**: App bar + **Learn shell disclaimer** strip (persistent) + scroll body in **Canonical Learn order** + optional **Learn suggested link** at top of scroll.
- **Foundation**: Carousel or horizontal list of expandable “insight” cards (content only; no numeric prevalence claims with false precision).
- **How-to**: Segment or chips for **Anatomy track** (default from **Gender identity** where `male` / `female` map cleanly; explicit chooser for `nonBinary` or override).
- **Dos/don’ts**: Two-column or paired list with clear visual affordances (check / cross), aligned with **Learn voice** for warnings.
- **Guided movement**: Accordions per drill; numbered steps; optional still images; no Rive/Lottie requirement for v1.
- **Troubleshooter**: Tabbed **Learn troubleshooter** (fixed order: urge → stress → hypertonicity-style; default index from **Troubleshooter default tab** rules).

## Data dependencies

- Read **`OnboardingProfile`** (`Symptom`, `ClinicalHistory.catheter`, `PrimaryGoal`, `GenderIdentity`) from existing scope (e.g. `OnboardingGate` via `OnboardingScope`) or equivalent profile store. **`hasActiveCatheter`** may use `profile.hasCatheter` or the denormalized `snapshot.catheterActive` when the gate snapshot is authoritative for UI.
- Derive booleans: `hasHypertonicityRiskSymptom`, `hasActiveCatheter`, `trainingPivotActive` (respect override flag once implemented), `trainingPivotOverrideActive`.
- **Training pivot override**: new persisted preference if not present today (acknowledgment + optional re-prompt when hypertonicity-risk symptoms reconfirmed — see CONTEXT relationships).

## Implementation checklist

1. **Strings**: Add ARB keys for all Learn copy; no raw user-visible literals in widgets for Learn.
2. **Content model**: Define bundled models (e.g. JSON under `assets/` or Dart constants) for cards, sections, troubleshooter tabs; version in code comment or `package_info` if needed.
3. **`LearnScreen`**: Compose sections; apply catheter banner + disclaimer; hide or soften exercise CTAs when **Active catheter**.
4. **Training surfaces** (outside this file): When `trainingPivotActive && !hasActiveCatheter`, apply pivot behavior agreed in CONTEXT (de-emphasize aggressive strengthening); when `hasActiveCatheter`, single dominant message on those surfaces.
5. **Settings**: Add **Training pivot override** flow (checkbox acknowledgment).
6. **QA**: Matrix test catheter + pivot + urge symptom + override + non-binary gender.

## References

- [Local vertical slices (tasks)](../tasks/learn-tab-vertical-slices.md) — implementation order without GitHub issues.
- [CONTEXT.md](../../../CONTEXT.md) — domain language and relationships.
- Current placeholder: `lib/features/learn/presentation/learn_screen.dart`.
- Profile enums: `lib/features/onboarding/domain/onboarding_profile.dart`.

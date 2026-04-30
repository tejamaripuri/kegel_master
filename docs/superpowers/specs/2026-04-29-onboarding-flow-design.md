# Onboarding flow — design

**Date:** 2026-04-29  
**Status:** Approved (conversation).

## Goals

- Show a **clinically informed onboarding flow** before the user reaches the main **Home** experience, capturing demographics, goals, symptoms, and clinical history.
- **Segment** users so exercise variables and UX (**cues**, **session timings** where applicable, **shell access**) reflect **gender**, **primary goal**, **age band**, and **clinical history** (and **catheter** for gating)—not a single default for everyone. **Symptoms** are collected for segmentation **later**; **v1** does not change the exercise prescription from symptoms alone.
- Enforce **safety rules:** **catheter** → exercises suspended with a clear warning and **Learn-only** app surface until state is cleared.
- **Capture** symptom answers (including **chronic pelvic pain**) on the persisted profile for **future** plan personalization; **v1 does not** apply a separate session prescription or persisted derived flag from that answer.
- **Persist** completion and profile **locally**; onboarding is **one-time** until the user triggers **reset** from **Settings** (full re-run including disclaimer).

## Non-goals (v1)

- Cloud sync, accounts, or clinician-facing dashboards.
- User-editable profile fields in Settings beyond **reset onboarding** (no per-field edit UI).
- Legal review of disclaimer copy (placeholder acceptable; product owner replaces before release).
- Final clinical validation of numeric timing tables (initial values are **tunable constants** with a clear single source of truth).
- Dynamic A/B testing of question order or copy.
- Symptom-driven session plans (e.g. down-training for chronic pelvic pain); deferred until a future release uses stored **`profile`**.

## Architecture decision

Use **GoRouter-first** onboarding: top-level **`/onboarding`** (and optional step sub-routes or in-wizard state), with a **single `redirect` policy** that reads persisted flags and sends the user to onboarding, **catheter / Learn-only** mode, or the main shell. Avoid a second parallel navigator above `MaterialApp.router`.

## Routing and gates

### Onboarding incomplete

- If **`onboardingComplete == false`**, any entry (including **`/`** and **`/home`**) **redirects to `/onboarding`** (first step = Disclaimer).
- After successful completion, navigate to **`/home`** (or equivalent canonical shell entry).

### Catheter active (post-onboarding)

- Persist **`catheterActive == true`** when the user selects **Currently using a catheter** in clinical history.
- **Precedence:** **Catheter rules override** other onboarding outcomes for **shell access** until **`catheterActive`** is cleared (**Session** is unreachable in this mode).

**Learn-only policy (approved option C):**

- **Allow:** **`/learn`**, **`/settings`** (Settings must remain reachable so the user can read reset/disclaimer context and **reset onboarding**).
- **Block:** **`/home`**, **`/progress`**, **`/session`**. Attempts to open those paths **redirect to `/learn`**.
- Show a **persistent banner** on Learn (and optionally Settings) explaining that **pelvic floor exercises are suspended** until the catheter is removed and the user has completed onboarding again without selecting catheter—or equivalent clinical clearance (copy is non-clinical “see your care team” framing).

### Chronic pelvic pain (and other symptoms)

- **v1:** Only stored inside **`profile`** (symptoms list). No extra persisted flag and **no** change to **`SessionPrescription`**, shell gates, or session copy based on this answer. A future release may introduce **down-training / relaxation** plans (or other tailoring) using the stored profile.

### Settings reset

- **Reset onboarding** clears: **`onboardingComplete`**, serialized **profile**, **`catheterActive`**, and any other derived fields; optionally clears **`disclaimerAcceptedAt`** so disclaimer runs again (recommended for consistency).
- After confirm dialog, navigate to **`/onboarding`** (Disclaimer first).

## Onboarding screens and validation

### Step 0 — Disclaimer

- **Full-screen** disclaimer (not medical advice, consult a clinician, stop if pain, etc.).
- User must tap **Accept** to continue (exact gating: optional “scroll to end to enable Accept”—product choice; if omitted, Accept is always available once screen is read).
- Persist **`disclaimerAcceptedAt`** (timestamp) on Accept.

### Step 1 — Gender identity (single choice)

- **Male** | **Female** | **Non-binary**
- **Impact:** Anatomical visualization keys and **cue copy** (e.g. anatomically appropriate language vs neutral metaphors). Implementation may ship **copy-only** cues before illustrations exist.

### Step 2 — Primary goal (single choice)

- Postpartum recovery  
- Post-surgical recovery (prostate)  
- Prevention / maintenance  
- Sexual performance enhancement  
- Incontinence management  

**Impact:** Drives **Learn** emphasis tags and **default session parameter** profile (gentler presets for post-surgical/postpartum where applicable). Exact numeric mapping lives in code constants (Section: Mapping tables).

### Step 3 — Age group (single choice)

- **18–34** | **35–54** | **55+**  
- **Impact:** Adjust **rest-to-work** emphasis (longer relax / buffer vs squeeze for older bands to reflect age-related muscle change). Numbers are **tunable**.

### Step 4 — Symptoms (multi-select)

- Leaking when coughing / sneezing  
- Sudden, intense urges to go  
- Difficulty starting a stream  
- Chronic pelvic pain or pain during intimacy  
- None  

**Validation:** **None** is **mutually exclusive** with all other options (choosing **None** clears others; choosing any other clears **None**).

**Impact:** **v1** — no app behavior change from individual symptom choices; data retained for **future** plan logic.

### Step 5 — Clinical history (multi-select)

- Recently gave birth (0–8 weeks)  
- Recent prostate surgery  
- Currently using a catheter  
- None  

**Validation:** **None** mutually exclusive as above.

**Impact:**

- **Catheter** → after onboarding commit, set **`catheterActive`**, show **Safety warning** screen (blocking copy + **I understand**) then enter app in **Learn-only** mode.
- Other flags inform **Learn** tags and **session presets** (gentler defaults where overlapping with goals).

### Step 6 — Summary

- Display all answers; **Edit** returns to the relevant step; **Confirm** commits persistence, sets **`onboardingComplete = true`**, then navigates to **`/home`** unless **catheter** forces post-warning entry into **Learn-only** (still set complete so redirect logic does not loop into onboarding).

## Persistence

- **v1:** Local storage only, e.g. **`shared_preferences`** with either a **single JSON blob** (`onboarding_profile_v1`) plus **`schemaVersion`**, or equivalent key set. Single blob preferred for atomic reset.
- **Keys / fields (conceptual):** `schemaVersion`, `onboardingComplete`, `disclaimerAcceptedAt`, `profile` (raw answers), **`catheterActive`** (denormalized for fast redirect; may be recomputed from `profile` on read if the team prefers a single source of truth).

## Domain model

- Immutable **`OnboardingProfile`** (enums + structured multi-selects).
- **Pure functions** (or a small service) **`SessionPrescription fromProfile(OnboardingProfile)`** returning **`SessionConfig` overrides** (or equivalent) relative to `SessionConfig.defaults` from **age**, **primary goal**, **clinical history** (except catheter, which gates access rather than tuning timings while active), and **gender** (cues / copy IDs). **Symptoms** (including chronic pelvic pain) are **not** inputs to v1 prescription; reserve for a future **`fromProfile`** revision.

## Mapping tables (initial heuristics)

Values are **placeholders** until clinically signed off; keep all numbers in **one module** for tuning.

### Age band → timing emphasis

| Age band | Direction (vs defaults) |
|----------|-------------------------|
| 18–34    | Use `SessionConfig.defaults` relax/buffer/squeeze ratios as baseline. |
| 35–54    | Slightly **longer relax** and/or **buffer** (modest increase). |
| 55+      | **Longer relax** and **buffer**; optionally **fewer reps per set** or **fewer target sets** if needed for safety copy alignment. |

### Primary goal → preset bias

| Goal | Direction |
|------|-----------|
| Postpartum / Post-surgical (prostate) | **Gentler** volume: lower `repsPerSet` and/or `targetSets`, longer buffers vs squeeze. |
| Prevention / maintenance | Near defaults. |
| Sexual performance | Slight increase in work relative to rest only if clinically acceptable. |
| Incontinence management | Moderate endurance bias; align with age adjustments. |

### Gender → cues

- Map to **cue template IDs** and future **asset IDs**; non-binary uses **neutral** cue set unless user preference is added later.

## Session, Home, Progress, Learn

- **Session:** **v1** prescription from **`fromProfile`** as above. If **`catheterActive`** → route **not reachable**; redirect to **`/learn`**.
- **Home / Progress:** In catheter mode, **unavailable** (redirect). **v1** does not special-case other symptom answers in Home/Progress copy (future releases may).
- **Learn:** Always allowed in catheter mode; optional future: filter or order content by **goal**, **gender**, and **symptoms**.

## Testing (v1)

- **Unit tests:** `redirect` matrix (incomplete onboarding; complete + catheter; complete + catheter with profile that also includes chronic pelvic pain → catheter wins; reset clears state).
- **Unit tests:** Multi-select **None** exclusivity.
- **Unit tests:** `fromProfile` outputs for representative profiles (symptom choices do not change v1 outputs; include edge: only “None” symptoms).

## References

- [Routing design](2026-04-25-routing-design.md) — shell and `/session` placement.  
- [Home & session screens design](2026-04-26-home-session-screens-design.md) — `SessionConfig` and phase semantics.

# Kegel Master

The core domain language and relationships for the Kegel Master application.

## Language

**Reminder**:
A generic daily prompt sent to the user at a single configured time of day to encourage them to perform their exercises, not tied to a specific scheduled workout session.
_Avoid_: Notification, alarm

**Snooze**:
An action that defers a fired **Reminder** by exactly 1 hour, scheduling a one-off prompt.

**Anatomy track**:
A Learn content grouping that differs by pelvic structure and typical clinical cues; choosing a track is about which body areas apply, not about personal identity.
_Avoid_: Female guide, Male guide (as stand-ins for the person)

**Gender identity**:
How the user identifies in onboarding; it may suggest a default **Anatomy track** but must not gate or relabel the user.

**Primary goal**:
The user's main reason for using the app, chosen during onboarding (for example postpartum recovery or incontinence management); it informs lightweight personalization such as the **Learn suggested link** but does not reorder Learn sections in v1.

**Learn educational framing**:
Informational wellness content under one persistent **Learn shell disclaimer**; population or physiology figures are expressed in qualitative language, not as cited statistics, and Learn does not include reference lists or source drawers.
_Avoid_: Numeric prevalence claims with implied precision, per-card legal walls as the main trust mechanism

**Learn shell disclaimer**:
The brief, always-visible notice on the Learn area that this material is educational and not a substitute for professional care.

**Learn voice**:
Body copy is plain-language first; clinical vocabulary appears only as optional short asides (for example after a tap). Safety and contraindication wording stays direct and is never playful or euphemistic.
_Avoid_: Leading with unexplained clinical jargon, cutesy phrasing in warnings

**Learn privacy expansion**:
Touch-based or insertion-based verification steps in **Learn** sit behind an explicit expand control so the default read stays sensory-cue first and less exposed on screen.
_Avoid_: Showing full tactile instructions without a deliberate opt-in

**Hypertonicity-risk symptom**:
Chronic pelvic pain or difficulty starting the urinary stream when chosen as onboarding **Symptom** values; **either one alone** triggers a **Training pivot**.

**Symptom**:
A self-reported pelvic or urinary issue captured during onboarding, used with other profile inputs to personalize guidance and safety-related behavior such as a **Training pivot**.

**Active catheter**:
The user indicated a catheter is in use during onboarding; app-led pelvic floor exercise sessions are suspended in favor of their care team.

**Training pivot**:
When a **Hypertonicity-risk symptom** is present, training flows de-emphasize aggressive pelvic floor strengthening and align with down-training emphasis in **Learn**, rather than warning only inside Learn.
_Avoid_: Hard-blocking all exercise without an explicit user path; treating Learn as the only place contraindications appear

**Learn troubleshooter**:
The Learn subsection that presents urge, stress, and hypertonicity-style response guidance in sibling tabs in that fixed order (implementation tab index 0 = urge).

**Troubleshooter default tab**:
The tab shown first when opening the **Learn troubleshooter**, chosen by best match to onboarding **Symptom** and **Training pivot** state (**Training pivot** wins when it applies); every tab stays available. When no signal maps cleanly, the **urge** tab (first in that order) opens with neutral copy inviting the user to pick what fits.

**Training pivot override**:
The user's explicit, acknowledged choice to resume standard strengthening emphasis even while a **Hypertonicity-risk symptom** remains on file; the app may surface the pivot again if those symptoms are reconfirmed later.
_Avoid_: Silently ignoring risk signals without a deliberate acknowledgment step

**Learn guided movement (MVP)**:
Integration-style movement content in Learn is delivered as clear ordered steps with optional still imagery first; bespoke interactive animation is out of scope for the initial release.
_Avoid_: Blocking Learn on custom motion assets

**Learn release bundle**:
The Learn library for v1 is versioned and shipped inside the application build (structured copy and assets), not loaded from a remote CMS or OTA content layer in the first release.
_Avoid_: Treating live-updated Learn copy as a v1 dependency

**Learn localization (MVP)**:
Only English ships in v1, but Learn user-facing strings are authored through the app's standard localization mechanism so additional locales can be added without restructuring screens.
_Avoid_: Scattering user-visible Learn copy outside translatable bundles

**Canonical Learn order**:
The fixed sequence of Learn sections (foundation facts, anatomy-track how-to, clinical dos and don'ts, integration-style guided movement, troubleshooter) that every user sees in v1.

**Learn suggested link**:
An optional callout near the top of Learn that deep-links into the subsection that best matches **Primary goal**, **Symptom**, and **Training pivot**, without changing the **Canonical Learn order**. When no subsection is a clear match, omit the callout or use neutral copy that does not imply a false match or a dead link.

## Relationships

- A **Reminder** prompts the user to perform exercises generally.
- Completing a workout session cancels the **Reminder** for that specific day if it hasn't fired yet.
- **Snoozing** a **Reminder** schedules a one-off **Snooze Reminder** 1 hour later, leaving the repeating daily schedule unaffected.
- **Gender identity** can suggest a default **Anatomy track**; the user can always switch tracks regardless of identity.
- A **Training pivot** is triggered by any **Hypertonicity-risk symptom**; **Learn** and training surfaces stay consistent with that pivot.
- A **Training pivot override** relaxes that pivot until symptoms or acknowledgment flow changes; it does not erase stored **Symptom** data by itself.
- Removing **Hypertonicity-risk symptom** entries from the profile ends a **Training pivot** without needing an override.
- The **Troubleshooter default tab** follows **Symptom** and **Training pivot** signals; **Training pivot** takes precedence for that default when it applies.
- When **Active catheter** applies, it takes precedence on training-oriented surfaces over **Training pivot** messaging so the user sees one coherent safety story; **Learn** stays educational-only without pushing exercise.
- **Canonical Learn order** is fixed in v1; a **Learn suggested link** may reflect **Primary goal**, **Symptom**, and **Training pivot** without reordering sections.

## Example dialogue

> **Dev:** "Does a **Reminder** fire only when a user has a workout scheduled for today?"
> **Domain expert:** "No — a **Reminder** is just a generic prompt to keep up the habit, it isn't linked to specific workout sessions."

> **Dev:** "Should the Learn tab say Female/Male guide?"
> **Domain expert:** "No — use **Anatomy track** language. **Gender identity** isn't the same thing as which pelvic cues apply to someone."

> **Dev:** "Can we show '70% slow-twitch fibers' with a journal link?"
> **Domain expert:** "No — **Learn educational framing** is qualitative copy plus the **Learn shell disclaimer** only; no citations in Learn."

> **Dev:** "If someone reports pelvic pain, do we only warn them in Learn?"
> **Domain expert:** "No — trigger a **Training pivot** so workouts aren't pushing heavy Kegels while Learn explains down-training."

> **Dev:** "Do they need both pelvic pain and a weak stream?"
> **Domain expert:** "No — **either** counts as a **Hypertonicity-risk symptom** and triggers the pivot."

> **Dev:** "What if their PT cleared Kegels but onboarding still shows pain?"
> **Domain expert:** "They use a **Training pivot override** — explicit acknowledgment, not a hidden switch."

> **Dev:** "Which troubleshooter tab opens first?"
> **Domain expert:** "Use the **Troubleshooter default tab** from their **Symptom** and **Training pivot** — pivot wins if both urge and pivot could apply; every tab stays visible."

> **Dev:** "Do we need Rive animations for the bridge and elevator on day one?"
> **Domain expert:** "No — **Learn guided movement (MVP)** is steps and stills; motion comes later."

> **Dev:** "They have a catheter and pelvic pain — two banners on Home?"
> **Domain expert:** "No — **Active catheter** wins on training surfaces; pivot detail can live in **Learn** without stacking CTAs where sessions are already off."

> **Dev:** "Does Learn copy come from a headless CMS at launch?"
> **Domain expert:** "No — v1 uses the **Learn release bundle** inside the app."

> **Dev:** "Do we ship Spanish Learn on day one?"
> **Domain expert:** "No — **Learn localization (MVP)** is English only, but strings go through the normal l10n path."

> **Dev:** "Should postpartum users see the troubleshooter before foundation facts?"
> **Domain expert:** "No — keep **Canonical Learn order**; use a **Learn suggested link** if we want to nudge them somewhere useful."

> **Dev:** "Should we open with 'detrusor overactivity'?"
> **Domain expert:** "No — **Learn voice** is plain first; clinical words are optional detail, except warnings stay blunt."

> **Dev:** "Put the finger check in the first screenful?"
> **Domain expert:** "No — that's **Learn privacy expansion**; opt-in, not inline by default."

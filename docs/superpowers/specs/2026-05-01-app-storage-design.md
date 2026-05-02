# App storage (preferences, session history, streaks) — design

**Date:** 2026-05-01  
**Status:** Approved (conversation).

## Goals

- **Persist user preferences** (app settings and a **mirrored effective `SessionConfig`**) with **local storage always available** and sufficient for full core UX **without network or accounts**.
- **Persist ended session runs** as **append-only history** (no mid-session timer resume in this design).
- **Derive streaks** from completed runs using agreed rules; avoid a second competing source of truth for streaks.
- **Reserve a clean seam** for **optional Firebase** later (upload / merge) without making the app depend on cloud for reads or writes.

## Non-goals (this spec)

- Implementing Firebase SDK, security rules, or sync UI.
- Server-side analytics pipelines.
- Mid-session **resume** persistence (user chose **completed-history-only** scope for “session information”).
- Migrating existing **onboarding** persistence into the new store (keep **separate** boundaries; see Architecture).

## Requirements summary (from product decisions)

| Topic | Decision |
|--------|-----------|
| Session history scope | **Append-only** rows when a run **ends**; **no** persisted in-progress timer state. |
| Run outcomes | Each row records **`completed`** or **`abandoned`** (and optional counters such as skips when available from the engine). |
| Streak “active day” | **≥1** run with **`outcome == completed`** on a **calendar day** (device **local timezone**). Abandoned-only days do **not** count. |
| Calendar bucketing | Use **`endedAt`** for assigning a run to a calendar day (single canonical choice). |
| User preferences | **App settings** plus **explicit mirror** of **`SessionConfig`** as the **effective plan** when the user edits timing outside onboarding. |
| Effective plan resolution | If **mirror is present** → use mirror; **else** derive from onboarding profile (`sessionPrescriptionFromProfile` behavior today). Clearing mirror = “follow onboarding prescription again” (explicit user action from Settings or equivalent). |
| Cloud | **Fully local-first**; Firebase (or similar) is **optional** later—never required to record a session or show streaks. |

## Architecture

### Boundary: onboarding vs progress

- **Onboarding** continues to use **`OnboardingPersistence`** and **`SharedPreferences`** keys as today (`lib/features/onboarding/data/onboarding_persistence.dart`). This spec does **not** fold onboarding blobs into the new database to limit churn and keep consent/profile concerns isolated.
- **Progress stack** (session run history, user prefs including `SessionConfig` mirror, optional future cached aggregates) lives behind **new** repository-style ports implemented with **recommended** on-device **SQLite** (e.g. **Drift**).

### Ports and implementations

- Define narrow **domain-facing interfaces**, for example:
  - **`SessionHistoryStore`**: append run, query by time range, stream or watch for UI.
  - **`UserPreferencesStore`**: read/write settings and **`SessionConfig?` mirror** with schema version.
- **Local implementation** is the **only** implementation required for MVP; it is the **source of truth** on device.
- **Optional future `FirebaseProgressSync`** (illustrative name): reacts to local commits (or periodic jobs), uploads new rows; on sign-in, **merges into local** with deterministic rules (e.g. union by stable **`id`**, UUID client-generated). **Reads for core UX** remain **local**.

### Recommended storage engine

- **Primary recommendation:** **one SQLite database** (via **Drift**) holding **session run table(s)** and **preferences** (typed table and/or small KV with JSON for mirror).
- **Acceptable alternative:** **split** stores—**`SharedPreferences`** for prefs + mirror, **SQLite** only for runs—if the team wants minimal change to key-value habits; trade-off is **two** systems to init and migrate.

## Data model

### Session run row

| Field | Type | Notes |
|--------|------|--------|
| `id` | String (UUID) | Client-generated; stable for future sync. |
| `startedAt` | DateTime (UTC stored) | When the user started the run. |
| `endedAt` | DateTime (UTC stored) | When the run ended; used for **calendar bucketing** and ordering. |
| `configSnapshot` | JSON or normalized columns | **Immutable** copy of `SessionConfig` fields at end of run. |
| `outcome` | enum | `completed` \| `abandoned`. |
| `skippedPhaseCount` | int (optional) | If exposed by engine at end time. |

**Invariant:** row is written **once** when the session **terminates** (completed or user-confirmed early end).

### User preferences

- **Settings** rows or KV: theme, sound/haptics, reminder fields, etc., as product requires; include **`schemaVersion`** for migrations.
- **`sessionConfigMirror`**: nullable serialized **`SessionConfig`**. When non-null, it is the **effective** prescription for “start session” defaults (subject to resolution rule below). **Reset-to-onboarding** clears this field.

### Effective `SessionConfig` resolution

1. If **`sessionConfigMirror` != null** → use mirror.
2. Else if onboarding profile available → **`sessionPrescriptionFromProfile(profile)`**.
3. Else → **`SessionConfig.defaults`** (same as current router fallback behavior).

Call sites that today only read onboarding should be updated to go through a **single resolver** (application layer) to avoid drift.

## Streaks

- **Derived only** from **`SessionHistoryStore`** query: filter **`outcome == completed`**, bucket **`endedAt`** into **local calendar dates**, apply streak definition:
  - A **qualifying day** has **≥1** completed run.
  - **Current streak (canonical):** Build the set of **qualifying local dates**. Let **anchor** be **today’s date** if it qualifies; **otherwise yesterday’s date** if it qualifies (so “not yet exercised today” does not zero a streak that is still alive through yesterday). If **neither** qualifies, **current streak = 0** (the chain is broken into the past). If **anchor** qualifies, walk **backward** one calendar day at a time from **anchor**, counting **consecutive** qualifying days until a gap; that count is the **current streak**.
  - **Best streak:** over the full timeline, the maximum length of any run of **consecutive** qualifying local dates (recomputable from full history; optional cache later).
- **No** separate `streaks` table required for correctness; optional **cache** in prefs acceptable later with invalidation on append.

## Errors and consistency

- **Write path:** append run in a **single transaction**; surface failures to UI/repository (user-visible retry or non-destructive error state).
- **Migrations:** Drift (or sqflite) **schema version** upgrades must handle additive columns; never silently drop run history.

## Testing

- **Unit tests:** calendar bucketing from `endedAt` + timezone edge cases you care about (fixed clock / `DateTime` stubs); streak calculation from sorted qualifying dates.
- **Store tests:** in-memory SQLite / Drift test DB—append row, query range, outcomes filter.

## Relation to future Firebase

- **IDs:** UUID per run from client enables idempotent upload.
- **Conflict:** same `id` from two devices is unlikely if UUID is random; if duplicates occur, last-writer-wins per field or “reject duplicate insert” policy—**decide at implementation** when Firebase is introduced; this spec only requires **deterministic** merge documentation at that time.
- **Privacy:** run rows contain **timing** and **outcomes**, not medical narrative; still treat as **sensitive health-adjacent** data for encryption and policy when cloud is added.

## Open items (intentionally deferred)

- Exact **Settings** fields for v1 prefs (theme/reminder toggles) — add when those screens exist.
- Whether to **backfill** mirror from first successful session post-onboarding — product choice; default **no** (mirror null until user edits).

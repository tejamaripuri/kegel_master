# Progress tab — training calendar and day detail — design

**Date:** 2026-05-04  
**Status:** Approved (conversation).

## Goals

- Show a **month calendar** on the **Progress** tab (`/progress`).
- **Mark** calendar days where the user had **at least one completed** session, consistent with existing streak rules (local calendar day from **`endedAt`** UTC instant).
- On **selecting any day**, show a **modal bottom sheet** listing **all sessions that ended on that local calendar day** (completed and abandoned), with enough detail to distinguish outcomes and in-run skip usage.

## Non-goals

- Changing **streak calculation** semantics or replacing `completedEndedAtUtc()` for the streak line in the same release (calendar may use a **separate** `listAllRuns()` load; see Data loading).
- New persistence tables or migrations (reuse **`SessionHistoryStore.listAllRuns()`**).
- Deep links, notifications, or cross-tab state packages beyond current app patterns.
- Editing or deleting history from the sheet.

## Product rules

| Topic | Decision |
|--------|-----------|
| “Trained” / marked day | Local day has **≥1** run with **`outcome == completed`**, keyed by **`dateOnlyLocal(endedAt)`** (same idea as `qualifyingLocalDatesFromEndedAt` in `streak_calculator.dart`). |
| Day list contents | **All** runs with **`dateOnlyLocal(endedAt)`** equal to the selected day (completed **and** abandoned). |
| “Skipped” in copy | **Abandoned** runs are labeled as such; **`skippedPhaseCount`** is **secondary** text (phases skipped inside that run—not the same as abandoning). |
| Tappable days | **Every** day in the visible month is tappable. Empty days show a clear **no sessions** empty state in the sheet. |
| Navigation | **Bottom sheet** only; **no** new route. |

## Dependencies

- Add **`table_calendar`** for the month grid and month navigation, unless implementation explicitly chooses a hand-built grid (non-goal for this spec’s recommended path).

## Architecture

### Screen composition

- **`ProgressScreen`** keeps the **streak** block and its existing **`completedEndedAtUtc()`** `Future` unchanged.
- Below streak, insert a **calendar card** that loads history via **`listAllRuns()`** when the tab becomes current (same **route-is-current** refresh trigger as streak uses today in `didChangeDependencies`).
- Extracted widgets (names illustrative): **`TrainingCalendarCard`** (month UI + markers + `onDaySelected`), **`DaySessionsSheet`** (sheet body: date header + list).

### Derived data (in memory)

From **`List<SessionHistoryEntry>`** (newest-first per store contract):

1. **`markedLocalDates`:** `Set<DateTime>` of **date-only local** values for runs where **`outcome == SessionOutcome.completed`**.
2. **`runsByLocalDay`:** `Map<DateTime, List<SessionHistoryEntry>>` keyed by **date-only local** of **`endedAt`**, values sorted **newest first** within the day.

Reuse **`dateOnlyLocal`** from `streak_calculator.dart` for bucketing (import shared helper; do not duplicate logic).

### Data loading

- **v1:** Use **two** loads on tab focus: existing **`completedEndedAtUtc()`** for streak + **`listAllRuns()`** for calendar derivation. Avoids refactoring streak into the same future in the same change.
- **Follow-up (optional):** Single query + derive streak markers from the same list to reduce I/O; not required for this spec.

## UX

- **Default visible month:** Month containing **today** (local).
- **Markers:** Visual indicator only on **`markedLocalDates`**; unmarked days have no “trained” marker.
- **Loading:** Calendar card shows a **compact loading** state (or skeleton) while `listAllRuns()` is pending; avoid a large blank region.
- **Error:** If `listAllRuns()` fails, show a **short inline error** in the calendar card and **no** markers; streak behavior stays independent.
- **Sheet:** Formatted **date** title; scrollable list of runs; each row: **outcome** (completed vs abandoned), **ended time** (local); show **phases skipped** as secondary text **only if** `skippedPhaseCount > 0`; dismiss via drag or barrier.

## Testing

- **Unit tests** for grouping: given fixed `SessionHistoryEntry` lists, assert **`markedLocalDates`**, **`runsByLocalDay`** keys and per-day ordering, and edge cases (UTC `endedAt` spanning local midnight).
- **Optional widget test:** fake `SessionHistoryStore`, tap a day, expect sheet strings for a completed and an abandoned run.

## Relation to other docs

- Aligns with **calendar bucketing** and streak “active day” rules in [2026-05-01-app-storage-design.md](./2026-05-01-app-storage-design.md).
- Fits **feature-first** layout under `lib/features/progress/presentation/` per [ARCHITECTURE.md](../../ARCHITECTURE.md).

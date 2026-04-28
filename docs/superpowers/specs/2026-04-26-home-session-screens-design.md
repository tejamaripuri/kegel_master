# Home & session screens — design

**Date:** 2026-04-26  
**Status:** Approved (conversation).

## Goals

- **Home:** clear **Start** entry that begins a session on a **new full-screen screen**.
- **Session:** show **Squeeze** / **Relax** / **Between sets** phases with a **timer**, **Set** and **Rep** progress, and only **Skip** and **End session** (no pause).
- **Sets:** each **set** is **`repsPerSet`** consecutive **squeeze → relax** pairs; **buffer/rest** runs **only after a complete set**, before the first squeeze of the **next** set (no buffer after the final set).
- **Completion:** fixed **`targetSets`**; reaching **Done** counts as a completed session; **End session** before Done does **not** count. Model supports **skipped-phase / skipped-rep metadata** for future analytics; v1 may not surface it in UI.

## Non-goals (this spec)

- User-editable timings (deferred to Settings or later).
- Persistence to disk, streaks, Progress tab integration (session **result** type may exist in code for later wiring).
- Audio, haptics, lock-screen / background timers.
- Resume interrupted session from Home.

## Navigation

- **`/home`:** primary **Start** → `context.push('/session')` (or equivalent) so the session is a **separate route** above the tab shell.
- **`/session`:** **full-screen** route using the **root navigator** (sibling of `StatefulShellRoute`), so the **bottom tab bar is not visible** during a session. Aligns with [routing design](2026-04-25-routing-design.md) extension pattern without teaching the shell about session visibility.
- **Done:** `pop` back to the shell (single level). If the stack must be reset in a future variant, document `go('/home')` as an alternative; default is **pop**.
- **End session** (before Done): after confirmation when the user would abandon a counting run, **discard** — no completed-session record.
- **System back** (Android / predictive back): same rule as **End session** when a counting session is in progress (confirm, then discard). When **Done** is showing, back returns home **without** the abandon confirm.

## Home UI

- **`HomeScreen`:** minimal copy; dominant **Start** control (`FilledButton` or equivalent).
- Optional subtitle is allowed; **no** “resume session” in this spec.

## Session UI

- **Phase label:** one of **Squeeze**, **Relax**, **Between sets** (copy may use shorter strings if needed for layout).
- **Countdown** for the active phase (remaining seconds).
- **Progress:** **Set *x* of *targetSets***, **Rep *y* of *repsPerSet*** within the current set (rep index resets each set).
- **Actions:** **Skip** and **End session** only.

## SessionConfig (single source of truth)

One module (e.g. `lib/features/session/domain/session_config.dart` or `lib/core/session/session_config.dart`) defines at least:

| Field | Purpose |
|--------|--------|
| `squeezeSeconds` | Squeeze phase duration |
| `relaxSeconds` | Relax phase duration |
| `repsPerSet` | Squeeze→relax pairs per set |
| `targetSets` | Number of sets to reach Done |
| `bufferBetweenSetsSeconds` | Rest after a full set, before the next set’s first squeeze |

**Concrete default values** are chosen at implementation time (sensible MVP numbers); this spec does not fix the integers.

## Phase order

For `setIndex` from `1` to `targetSets`:

1. For `repIndex` from `1` to `repsPerSet`: **Squeeze** → **Relax** (immediate transition from relax to next rep’s squeeze when more reps remain in the set).
2. If `setIndex < targetSets`: **Between sets** (buffer), then start the next set at **Squeeze**.

After the **Relax** phase of the **last rep** of the **last set**, transition to **Done** (no buffer after the final set).

## Skip

- **Skip** immediately ends the **current phase** and moves to the **start of the next phase** in the sequence above (including from buffer into the next set’s first squeeze).
- **Tracking (for later):** increment a **skipped phase** counter whenever Skip ends **Squeeze**, **Relax**, or **Between sets** before natural completion. For future **“reps skipped”** reporting, treat a rep as contributing **one** skipped rep if **either** its squeeze **or** its relax was ended early by Skip (at most one per rep). Buffer ended early by Skip increments skipped phase count but does not by itself add a skipped rep.

## End session

- If the user would abandon before **Done**, show a **confirmation** dialog; on confirm, **pop** to home and **do not** emit a completed-session result.
- If **Done** is already active, **End session** is unnecessary or behaves as **Close** / back only—implementation may hide the button or map it to pop without confirm.

## Done state

- Show a clear **Done** state on `/session` (dialog or in-scaffold panel) with control to return home (`pop`).
- Emit or hold in memory a **completed session result** (`completed: true`, optional duration, skipped counters) for future persistence; v1 may not save it.

## State & architecture notes

- Timer driving phase transitions: **ticker- or timer-based** implementation is an implementation detail; phases must advance correctly when foregrounded (no background execution requirements in this spec).
- Global state package is **not required** by this spec; session state may live in the session route’s widget subtree until cross-feature needs appear (per [ARCHITECTURE.md](../../ARCHITECTURE.md)).

## Testing

- **Router:** from `/home`, push `/session`; after Done, pop returns to shell home.
- **Sequence:** phase order respects **reps per set**, **buffer only between sets**, no buffer after last set.
- **Skip:** remaining time jumps; next phase matches the ordered state machine.
- **End early:** confirmation path; assert **no** completed result (or explicit abandoned flag not counted).
- **Full run:** last relax → Done → home.

## Relation to other docs

- [Routing design](2026-04-25-routing-design.md): shell and tabs unchanged; **root-level `/session`** is an additive route.
- [ARCHITECTURE.md](../../ARCHITECTURE.md): update after implementation to mention `/session` and `SessionScreen` (or chosen names).

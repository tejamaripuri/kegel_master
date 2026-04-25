# Routing design — Kegel Master

**Date:** 2026-04-25  
**Status:** Approved (conversation) — implementation follows separately.

## Goals

- Preserve today’s UX: four bottom tabs, **`IndexedStack`** semantics (off-tab widgets stay mounted; state preserved when switching tabs).
- Avoid a dead end when the app later needs **path-based navigation**, **web URL bar sync**, **deep links**, or **notification targets** (not required in the first milestone).
- Start with **one primary screen per tab**; defer per-tab **navigation stacks** until a feature needs list → detail → session (or similar).

## Non-goals (this spec)

- Choosing a state-management package or persistence.
- Defining lesson/session IDs or API contracts.
- Implementing deep link domain configuration (Android App Links, iOS universal links, web hosting).

## Decision

Use **`go_router`** with a single **`GoRouter`** and a **`StatefulShellRoute.indexedStack`** so tab selection and route state stay aligned. Replace `MaterialApp(home: …)` with **`MaterialApp.router`**.

## Route table (initial)

| Path | Tab (order) | Screen |
|------|---------------|--------|
| `/home` | 0 — Home | `HomeScreen` |
| `/learn` | 1 — Learn | `LearnScreen` |
| `/progress` | 2 — Progress | `ProgressScreen` |
| `/settings` | 3 — Settings | `SettingsScreen` |

**Initial location:** `/home`. If the app is launched at `/`, a **`redirect`** to `/home` is acceptable and keeps a single canonical entry for the shell.

## Shell behavior

- **`StatefulShellRoute.indexedStack`** hosts four **`StatefulShellBranch`** instances, each with one top-level **`GoRoute`** in the initial milestone.
- The bottom **`NavigationBar`** uses **`StatefulNavigationShell`**: **`shell.goBranch(index)`** (and optional `initialLocation` / `restore` behavior per `go_router` APIs) instead of local `setState` on a tab index only. This keeps **URL (when enabled) and selected tab** consistent when web or deep links are added later.

## Extension points

### Nested stacks inside a tab

When a tab needs a stack (e.g. `/learn` → `/learn/:lessonId` → session player):

- Add **child `GoRoute`s`** under that branch’s subtree. Prefer extending the existing shell rather than introducing a second parallel navigation system.
- If independent **per-tab `Navigator` stacks** and back behavior become complex, evaluate migrating the shell to a pattern with explicit **`navigatorKey`s** per branch per `go_router` documentation for that release. No commitment in this milestone—only that the first implementation must not block it.

### Redirects and guards

- Use top-level **`redirect`** (and **`refreshListenable`** if auth or onboarding state is added) for global rules: signed-out users, incomplete onboarding, or “resume active session” without changing the four base paths.

### Errors

- Provide **`errorBuilder`** (or equivalent `GoRouter` error handling) for unknown paths; show a minimal “not found” UI and a way to return to **`/home`**.

### State restoration

- **`restorationScopeId`** on the router/shell is **optional** in the first implementation; document where to add it if OS-level restoration becomes a requirement.

## Testing

- Widget tests build **`MaterialApp.router`** with the same **`GoRouter`** configuration (or a test helper factory).
- Assert navigation by driving **`router.go` / `router.push`** and **`pumpAndSettle`**, then **`expect`** the intended screen types or keys.

## Relation to existing docs

[`docs/ARCHITECTURE.md`](../../ARCHITECTURE.md) describes the **current** `MaterialApp` + `MainNavigationShell` setup. After implementation, that document’s navigation section should be updated to match this spec so newcomers see one source of truth.

## Out of scope alternatives (recorded)

- **Stay on `IndexedStack` only:** fastest short term; larger migration when URLs or deep links are required.
- **Ad-hoc named routes without `go_router`:** workable for a few pushes; weaker fit for shell + web + deep links.

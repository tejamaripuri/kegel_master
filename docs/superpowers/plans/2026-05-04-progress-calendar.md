# Progress calendar & day sessions sheet — implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a month calendar on the Progress tab that marks local days with at least one completed session and opens a bottom sheet listing all runs that ended that local day (newest first), matching [2026-05-04-progress-calendar-design.md](../specs/2026-05-04-progress-calendar-design.md).

**Architecture:** Pure Dart derives `markedLocalDates` and `runsByLocalDay` from `listAllRuns()` using existing `dateOnlyLocal` from `streak_calculator.dart`. `ProgressScreen` keeps the streak `Future` unchanged and adds a second `Future` for runs, refreshed when the `/progress` route becomes current. UI is split into `TrainingCalendarCard` (`table_calendar`) and `DaySessionsSheet` (modal content).

**Tech stack:** Flutter 3.x, Material 3, `table_calendar` (^3.2.0, already in `pubspec.yaml`), `intl` (transitive — import `package:intl/intl.dart`), existing `SessionHistoryStore`, `InMemorySessionHistoryStore` for tests.

---

## File map

| File | Responsibility |
|------|----------------|
| `lib/features/progress/domain/training_calendar_index.dart` | Pure derivation: `TrainingCalendarIndex` + `deriveTrainingCalendarIndex(List<SessionHistoryEntry>)` |
| `lib/features/progress/presentation/day_sessions_sheet.dart` | Bottom sheet body: date header, list or empty state |
| `lib/features/progress/presentation/training_calendar_card.dart` | `TableCalendar`, markers, `onOpenDay` callback |
| `lib/features/progress/presentation/progress_screen.dart` | Second `Future`, wire card + sheet |
| `test/features/progress/domain/training_calendar_index_test.dart` | Unit tests for derivation |
| `test/features/progress/presentation/day_sessions_sheet_test.dart` | Widget tests for sheet content |
| `test/widget_test.dart` | Adjust Progress tab smoke expectations for new UI |

---

### Task 1: `TrainingCalendarIndex` derivation (TDD)

**Files:**

- Create: `lib/features/progress/domain/training_calendar_index.dart`
- Create: `test/features/progress/domain/training_calendar_index_test.dart`

- [ ] **Step 1: Add failing unit tests**

Create `test/features/progress/domain/training_calendar_index_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kegel_master/features/progress/domain/session_history_entry.dart';
import 'package:kegel_master/features/progress/domain/session_outcome.dart';
import 'package:kegel_master/features/progress/domain/training_calendar_index.dart';
import 'package:kegel_master/features/progress/domain/streak_calculator.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';

SessionHistoryEntry _entry({
  required String id,
  required DateTime endedAtUtc,
  required SessionOutcome outcome,
  int skippedPhaseCount = 0,
}) {
  return SessionHistoryEntry(
    id: id,
    startedAt: endedAtUtc.subtract(const Duration(minutes: 5)),
    endedAt: endedAtUtc,
    configSnapshot: SessionConfig.defaults,
    outcome: outcome,
    skippedPhaseCount: skippedPhaseCount,
  );
}

void main() {
  group('deriveTrainingCalendarIndex', () {
    test('marks only days with a completed run', () {
      final completedDay = DateTime.utc(2026, 5, 4, 14, 0);
      final abandonedSameLocal = DateTime.utc(2026, 5, 4, 18, 0);
      final runs = [
        _entry(id: 'a', endedAtUtc: abandonedSameLocal, outcome: SessionOutcome.abandoned),
        _entry(id: 'b', endedAtUtc: completedDay, outcome: SessionOutcome.completed),
      ];
      final index = deriveTrainingCalendarIndex(runs);
      expect(index.markedLocalDates, contains(dateOnlyLocal(completedDay)));
      expect(index.markedLocalDates.length, 1);
    });

    test('groups all runs by local ended day; newest first within a day', () {
      final d1 = DateTime.utc(2026, 5, 4, 8, 0);
      final d2 = DateTime.utc(2026, 5, 4, 20, 0);
      final otherDay = DateTime.utc(2026, 5, 5, 12, 0);
      final runs = [
        _entry(id: 'early', endedAtUtc: d1, outcome: SessionOutcome.completed),
        _entry(id: 'late', endedAtUtc: d2, outcome: SessionOutcome.abandoned),
        _entry(id: 'next', endedAtUtc: otherDay, outcome: SessionOutcome.completed),
      ];
      final index = deriveTrainingCalendarIndex(runs);
      final key = dateOnlyLocal(d1);
      final dayRuns = index.runsByLocalDay[key]!;
      expect(dayRuns.map((e) => e.id).toList(), ['late', 'early']);
    });

    test('empty input yields empty index', () {
      final index = deriveTrainingCalendarIndex(const []);
      expect(index.markedLocalDates, isEmpty);
      expect(index.runsByLocalDay, isEmpty);
    });
  });
}
```

- [ ] **Step 2: Run tests — expect failure**

Run:

```text
flutter test test/features/progress/domain/training_calendar_index_test.dart
```

Expected: compile error (`TrainingCalendarIndex` / `deriveTrainingCalendarIndex` not found).

- [ ] **Step 3: Implement derivation**

Create `lib/features/progress/domain/training_calendar_index.dart`:

```dart
import 'package:kegel_master/features/progress/domain/session_history_entry.dart';
import 'package:kegel_master/features/progress/domain/session_outcome.dart';
import 'package:kegel_master/features/progress/domain/streak_calculator.dart';

class TrainingCalendarIndex {
  const TrainingCalendarIndex({
    required this.markedLocalDates,
    required this.runsByLocalDay,
  });

  final Set<DateTime> markedLocalDates;
  final Map<DateTime, List<SessionHistoryEntry>> runsByLocalDay;
}

TrainingCalendarIndex deriveTrainingCalendarIndex(
  List<SessionHistoryEntry> runsNewestFirst,
) {
  final marked = <DateTime>{
    for (final r in runsNewestFirst)
      if (r.outcome == SessionOutcome.completed) dateOnlyLocal(r.endedAt),
  };

  final byDay = <DateTime, List<SessionHistoryEntry>>{};
  for (final r in runsNewestFirst) {
    final key = dateOnlyLocal(r.endedAt);
    byDay.putIfAbsent(key, () => <SessionHistoryEntry>[]).add(r);
  }
  for (final list in byDay.values) {
    list.sort((a, b) => b.endedAt.compareTo(a.endedAt));
  }

  return TrainingCalendarIndex(
    markedLocalDates: marked,
    runsByLocalDay: byDay,
  );
}
```

- [ ] **Step 4: Run tests — expect pass**

Run:

```text
flutter test test/features/progress/domain/training_calendar_index_test.dart
```

Expected: all tests passed.

- [ ] **Step 5: Commit**

```bash
git add lib/features/progress/domain/training_calendar_index.dart test/features/progress/domain/training_calendar_index_test.dart
git commit -m "feat(progress): derive training calendar index from session history"
```

---

### Task 2: `DaySessionsSheet` widget

**Files:**

- Create: `lib/features/progress/presentation/day_sessions_sheet.dart`
- Create: `test/features/progress/presentation/day_sessions_sheet_test.dart`

- [ ] **Step 1: Widget tests first**

Create `test/features/progress/presentation/day_sessions_sheet_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kegel_master/features/progress/domain/session_history_entry.dart';
import 'package:kegel_master/features/progress/domain/session_outcome.dart';
import 'package:kegel_master/features/progress/domain/streak_calculator.dart';
import 'package:kegel_master/features/progress/presentation/day_sessions_sheet.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';

void main() {
  testWidgets('shows empty copy when no runs', (WidgetTester tester) async {
    final day = DateTime(2026, 5, 4);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DaySessionsSheet(
            localDay: day,
            runs: const [],
          ),
        ),
      ),
    );
    expect(find.text('No sessions on this day.'), findsOneWidget);
  });

  testWidgets('shows outcome and phases skipped when > 0', (WidgetTester tester) async {
    final day = dateOnlyLocal(DateTime.utc(2026, 5, 4, 12));
    final runs = [
      SessionHistoryEntry(
        id: '1',
        startedAt: DateTime.utc(2026, 5, 4, 11),
        endedAt: DateTime.utc(2026, 5, 4, 11, 30),
        configSnapshot: SessionConfig.defaults,
        outcome: SessionOutcome.completed,
        skippedPhaseCount: 2,
      ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DaySessionsSheet(
            localDay: day,
            runs: runs,
          ),
        ),
      ),
    );
    expect(find.textContaining('Completed'), findsWidgets);
    expect(find.textContaining('Phases skipped: 2'), findsOneWidget);
  });
}
```

Adjust string expectations in Step 3 to match exact strings you put in the widget (`Completed` / `Abandoned` / `Phases skipped: N`).

- [ ] **Step 2: Run tests — expect failure**

Run:

```text
flutter test test/features/progress/presentation/day_sessions_sheet_test.dart
```

Expected: missing `DaySessionsSheet` or wrong text.

- [ ] **Step 3: Implement widget**

Create `lib/features/progress/presentation/day_sessions_sheet.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:kegel_master/features/progress/domain/session_history_entry.dart';
import 'package:kegel_master/features/progress/domain/session_outcome.dart';

class DaySessionsSheet extends StatelessWidget {
  const DaySessionsSheet({
    super.key,
    required this.localDay,
    required this.runs,
  });

  /// Date-only in local calendar (year, month, day; time ignored).
  final DateTime localDay;
  final List<SessionHistoryEntry> runs;

  static String _outcomeLabel(SessionOutcome o) {
    switch (o) {
      case SessionOutcome.completed:
        return 'Completed';
      case SessionOutcome.abandoned:
        return 'Abandoned';
    }
  }

  @override
  Widget build(BuildContext context) {
    final header = DateFormat.yMMMMEEEEd().format(localDay);
    final timeFmt = DateFormat.jm();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              header,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (runs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No sessions on this day.')),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: runs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final e = runs[i];
                    final endedLocal = e.endedAt.toLocal();
                    final subtitle = e.skippedPhaseCount > 0
                        ? 'Phases skipped: ${e.skippedPhaseCount}'
                        : null;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_outcomeLabel(e.outcome)),
                      subtitle: subtitle != null ? Text(subtitle) : null,
                      trailing: Text(timeFmt.format(endedLocal)),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

If the analyzer cannot resolve `intl`, add to `pubspec.yaml` under `dependencies:`:

```yaml
  intl: ^0.20.2
```

Then run `flutter pub get`.

- [ ] **Step 4: Run tests — expect pass**

Run:

```text
flutter test test/features/progress/presentation/day_sessions_sheet_test.dart
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/progress/presentation/day_sessions_sheet.dart test/features/progress/presentation/day_sessions_sheet_test.dart pubspec.yaml pubspec.lock
git commit -m "feat(progress): add day sessions bottom sheet content"
```

(Include `pubspec.yaml` / `pubspec.lock` only if you added `intl`.)

---

### Task 3: `TrainingCalendarCard`

**Files:**

- Create: `lib/features/progress/presentation/training_calendar_card.dart`

- [ ] **Step 1: Implement widget**

Create `lib/features/progress/presentation/training_calendar_card.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:kegel_master/features/progress/domain/training_calendar_index.dart';

typedef OnOpenTrainingDay = void Function(DateTime localDay);

class TrainingCalendarCard extends StatefulWidget {
  const TrainingCalendarCard({
    super.key,
    required this.index,
    required this.onOpenDay,
  });

  final TrainingCalendarIndex index;
  final OnOpenTrainingDay onOpenDay;

  @override
  State<TrainingCalendarCard> createState() => _TrainingCalendarCardState();
}

class _TrainingCalendarCardState extends State<TrainingCalendarCard> {
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _focusedDay = DateTime(n.year, n.month, n.day);
  }

  DateTime _normalizeDay(DateTime d) => DateTime(d.year, d.month, d.day);

  List<Object> _eventsForDay(DateTime day) {
    final key = _normalizeDay(day);
    if (widget.index.markedLocalDates.contains(key)) {
      return const [_Marked()];
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final first = DateTime.utc(2020, 1, 1);
    final last = DateTime.utc(2035, 12, 31);

    return TableCalendar<Object>(
      firstDay: first,
      lastDay: last,
      focusedDay: _focusedDay,
      eventLoader: _eventsForDay,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: 'Month'},
      onPageChanged: (focused) {
        setState(() => _focusedDay = focused);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() => _focusedDay = focusedDay);
        widget.onOpenDay(_normalizeDay(selectedDay));
      },
    );
  }
}

class _Marked {
  const _Marked();
}
```

Notes for implementers:

- `_Marked` is a private sentinel so `eventLoader` returns a non-empty list only on marked days (package shows default markers).
- If default marker styling is too subtle, add `calendarStyle` / `calendarBuilders` per [table_calendar](https://pub.dev/packages/table_calendar) docs.

- [ ] **Step 2: Analyze / fix lints**

Run:

```text
dart analyze lib/features/progress/presentation/training_calendar_card.dart
```

Expected: no issues.

- [ ] **Step 3: Commit**

```bash
git add lib/features/progress/presentation/training_calendar_card.dart
git commit -m "feat(progress): add training month calendar card"
```

---

### Task 4: Wire `ProgressScreen`

**Files:**

- Modify: `lib/features/progress/presentation/progress_screen.dart`

- [ ] **Step 1: Add second future and UI block**

In `_ProgressScreenState`:

1. Add `Future<List<SessionHistoryEntry>>? _runsFuture;`
2. In the same `didChangeDependencies` branch where `_wasRouteCurrent` flips to true, also assign  
   `_runsFuture = ProgressScope.of(context).sessionHistory.listAllRuns();`  
   (same `setState` branch as streak when refreshing).
3. After the streak `FutureBuilder` (and spacing), insert:
   - `const Text('Training calendar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))`
   - `SizedBox(height: 8)`
   - `FutureBuilder<List<SessionHistoryEntry>>` on `_runsFuture`:
     - **waiting:** `Text('Loading calendar…')` or small `CircularProgressIndicator`
     - **error:** `Text('Could not load calendar.')`
     - **data:** build `TrainingCalendarIndex` via `deriveTrainingCalendarIndex(snapshot.data!)`, then `TrainingCalendarCard( index: index, onOpenDay: (day) { showModalBottomSheet<void>( context: context, showDragHandle: true, isScrollControlled: true, builder: (ctx) => DaySessionsSheet( localDay: day, runs: index.runsByLocalDay[day] ?? const [], ), ); }, )`

Imports to add:

```dart
import 'package:kegel_master/features/progress/domain/session_history_entry.dart';
import 'package:kegel_master/features/progress/domain/training_calendar_index.dart';
import 'package:kegel_master/features/progress/presentation/day_sessions_sheet.dart';
import 'package:kegel_master/features/progress/presentation/training_calendar_card.dart';
```

- [ ] **Step 2: Run analyzer**

Run:

```text
dart analyze lib/features/progress/presentation/progress_screen.dart
```

Expected: no issues.

- [ ] **Step 3: Update smoke test**

Modify `test/widget_test.dart` in the Progress tab test: after switching to Progress, expect `find.text('Training calendar')` and optionally `find.byType(TableCalendar)` from `package:table_calendar/table_calendar.dart`.

Example addition after line that finds `'Your progress'`:

```dart
expect(find.text('Training calendar'), findsOneWidget);
```

- [ ] **Step 4: Full test suite**

Run:

```text
flutter test
```

Expected: all tests passed.

- [ ] **Step 5: Commit**

```bash
git add lib/features/progress/presentation/progress_screen.dart test/widget_test.dart
git commit -m "feat(progress): show training calendar and day session sheet"
```

---

### Task 5: Manual check

- [ ] **Step 1: Run app**

```text
flutter run
```

- [ ] **Step 2:** Complete one session from Home → Progress: day shows marker; tap day → sheet lists run; abandon a session on another day → that day is not marked if no completed run, but sheet still lists abandoned run when that day is opened from calendar.

- [ ] **Step 3:** No commit required (manual only).

---

## Plan self-review (spec coverage)

| Spec item | Task |
|-----------|------|
| Mark days with ≥1 completed (`endedAt` → `dateOnlyLocal`) | Task 1 + Task 3 `eventLoader` |
| Sheet lists all runs that ended that local day | Task 2 + Task 4 `runsByLocalDay[day] ?? []` |
| Abandoned labeled; phases skipped only if count > 0 | Task 2 |
| Any day tappable; empty sheet copy | Task 2 + Task 4 `onDaySelected` always opens sheet |
| Streak `Future` unchanged; separate `listAllRuns` | Task 4 |
| Loading / error for calendar only | Task 4 `FutureBuilder` |
| `table_calendar` | Task 3 (dependency already in `pubspec.yaml`) |
| Unit tests for grouping | Task 1 |
| Optional widget tests | Task 2 (sheet); full calendar tap optional |

**Placeholder scan:** None intentionally used.

**Type consistency:** `TrainingCalendarIndex` fields match `deriveTrainingCalendarIndex` return; sheet uses `SessionHistoryEntry` from domain.

---

Plan complete and saved to `docs/superpowers/plans/2026-05-04-progress-calendar.md`. Two execution options:

**1. Subagent-Driven (recommended)** — Dispatch a fresh subagent per task, review between tasks, fast iteration.

**2. Inline Execution** — Execute tasks in this session using executing-plans, batch execution with checkpoints for review.

Which approach?

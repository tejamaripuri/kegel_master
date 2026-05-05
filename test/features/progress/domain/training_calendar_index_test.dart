import 'package:flutter_test/flutter_test.dart';
import 'package:kegel_master/features/progress/domain/session_history_entry.dart';
import 'package:kegel_master/features/progress/domain/session_outcome.dart';
import 'package:kegel_master/features/progress/domain/streak_calculator.dart';
import 'package:kegel_master/features/progress/domain/training_calendar_index.dart';
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

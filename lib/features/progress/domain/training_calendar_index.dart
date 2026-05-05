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

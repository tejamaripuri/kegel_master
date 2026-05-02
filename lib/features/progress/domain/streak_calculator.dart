import 'dart:collection';

DateTime dateOnlyLocal(DateTime utcInstant) {
  final local = utcInstant.toLocal();
  return DateTime(local.year, local.month, local.day);
}

Set<DateTime> qualifyingLocalDatesFromEndedAt(
  Iterable<DateTime> completedEndedAtUtc,
) {
  return {
    for (final ended in completedEndedAtUtc) dateOnlyLocal(ended),
  };
}

DateTime _previousCalendarDay(DateTime dateOnlyLocal_) {
  return DateTime(
    dateOnlyLocal_.year,
    dateOnlyLocal_.month,
    dateOnlyLocal_.day - 1,
  );
}

int currentStreak({
  required Set<DateTime> qualifyingLocalDates,
  required DateTime now,
}) {
  final today = dateOnlyLocal(now);
  final yesterday = _previousCalendarDay(today);

  DateTime? anchor;
  if (qualifyingLocalDates.contains(today)) {
    anchor = today;
  } else if (qualifyingLocalDates.contains(yesterday)) {
    anchor = yesterday;
  } else {
    return 0;
  }

  var count = 0;
  var d = anchor;
  while (qualifyingLocalDates.contains(d)) {
    count++;
    d = _previousCalendarDay(d);
  }
  return count;
}

int bestStreak(Set<DateTime> qualifyingLocalDates) {
  if (qualifyingLocalDates.isEmpty) {
    return 0;
  }
  final sorted = SplayTreeSet<DateTime>.from(qualifyingLocalDates);
  var best = 1;
  var run = 1;
  DateTime? prev;
  for (final d in sorted) {
    if (prev != null) {
      final expectedNext = DateTime(prev.year, prev.month, prev.day + 1);
      if (d.year == expectedNext.year &&
          d.month == expectedNext.month &&
          d.day == expectedNext.day) {
        run++;
        if (run > best) {
          best = run;
        }
      } else {
        run = 1;
      }
    }
    prev = d;
  }
  return best;
}

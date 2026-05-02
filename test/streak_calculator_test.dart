import 'package:flutter_test/flutter_test.dart';
import 'package:kegel_master/features/progress/domain/streak_calculator.dart';

void main() {
  group('currentStreak', () {
    test('today qualifies — counts today and prior consecutive days', () {
      final now = DateTime(2024, 3, 10, 15, 30);
      final qualifying = <DateTime>{
        DateTime(2024, 3, 10),
        DateTime(2024, 3, 9),
        DateTime(2024, 3, 8),
      };
      expect(
        currentStreak(qualifyingLocalDates: qualifying, now: now),
        3,
      );
    });

    test(
        'today does not qualify, yesterday does — anchor yesterday and counts backward',
        () {
      final now = DateTime(2024, 3, 10, 9, 0);
      final qualifying = <DateTime>{
        DateTime(2024, 3, 9),
        DateTime(2024, 3, 8),
      };
      expect(
        currentStreak(qualifyingLocalDates: qualifying, now: now),
        2,
      );
    });

    test(
        'neither today nor yesterday qualifies — returns 0 despite older qualifying days',
        () {
      final now = DateTime(2024, 3, 10, 12, 0);
      final qualifying = <DateTime>{
        DateTime(2024, 3, 5),
        DateTime(2024, 3, 6),
        DateTime(2024, 3, 7),
      };
      expect(
        currentStreak(qualifyingLocalDates: qualifying, now: now),
        0,
      );
    });
  });

  group('bestStreak', () {
    test('prefers longest consecutive run over shorter scattered runs', () {
      final qualifying = <DateTime>{
        DateTime(2024, 6, 1),
        DateTime(2024, 6, 2),
        DateTime(2024, 6, 5),
        DateTime(2024, 6, 6),
        DateTime(2024, 6, 7),
        DateTime(2024, 6, 8),
      };
      expect(bestStreak(qualifying), 4);
    });
  });

  group('qualifyingLocalDatesFromEndedAt / dateOnlyLocal', () {
    test('two UTC instants on same local calendar day collapse to one date', () {
      final localMorning = DateTime(2020, 6, 15, 3);
      final localEvening = DateTime(2020, 6, 15, 21);
      final endedAtUtc = [localMorning.toUtc(), localEvening.toUtc()];
      final set = qualifyingLocalDatesFromEndedAt(endedAtUtc);
      expect(set, hasLength(1));
      expect(set.single, dateOnlyLocal(localMorning.toUtc()));
    });
  });
}

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

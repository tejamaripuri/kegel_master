import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kegel_master/features/progress/application/session_history_store.dart';
import 'package:kegel_master/features/progress/application/user_preferences_store.dart';
import 'package:kegel_master/features/progress/data/in_memory_progress_stores.dart';
import 'package:kegel_master/features/progress/domain/session_history_entry.dart';
import 'package:kegel_master/features/progress/domain/session_outcome.dart';
import 'package:kegel_master/features/progress/presentation/progress_scope.dart';
import 'package:kegel_master/features/progress/presentation/progress_screen.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';

class _CountingSessionHistory implements SessionHistoryStore {
  _CountingSessionHistory(this._inner);

  final SessionHistoryStore _inner;
  int listAllRunsCalls = 0;
  int completedEndedAtUtcCalls = 0;

  @override
  Future<void> appendRun(SessionHistoryEntry run) => _inner.appendRun(run);

  @override
  Future<List<SessionHistoryEntry>> listAllRuns() async {
    listAllRunsCalls++;
    return _inner.listAllRuns();
  }

  @override
  Future<List<DateTime>> completedEndedAtUtc() async {
    completedEndedAtUtcCalls++;
    return _inner.completedEndedAtUtc();
  }
}

class _TickerHarness extends StatefulWidget {
  const _TickerHarness({
    required this.tabActive,
    required this.sessionHistory,
    required this.userPreferences,
  });

  final bool tabActive;
  final SessionHistoryStore sessionHistory;
  final UserPreferencesStore userPreferences;

  @override
  State<_TickerHarness> createState() => _TickerHarnessState();
}

class _TickerHarnessState extends State<_TickerHarness> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TickerMode(
        enabled: widget.tabActive,
        child: ProgressScope(
          sessionHistory: widget.sessionHistory,
          userPreferences: widget.userPreferences,
          child: const ProgressScreen(),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('refetches when tab becomes active again (indexed stack)',
      (WidgetTester tester) async {
    final inner = InMemorySessionHistoryStore();
    final counting = _CountingSessionHistory(inner);
    final prefs = InMemoryUserPreferencesStore();
    await prefs.ensureSeedRow();

    Future<void> pumpActive(bool active) async {
      await tester.pumpWidget(
        _TickerHarness(
          tabActive: active,
          sessionHistory: counting,
          userPreferences: prefs,
        ),
      );
      await tester.pumpAndSettle();
    }

    await pumpActive(false);
    expect(counting.listAllRunsCalls, 0);

    await pumpActive(true);
    expect(counting.listAllRunsCalls, 1);

    await inner.appendRun(
      SessionHistoryEntry(
        id: 'a',
        startedAt: DateTime.utc(2026, 5, 4, 10),
        endedAt: DateTime.utc(2026, 5, 4, 10, 30),
        configSnapshot: SessionConfig.defaults,
        outcome: SessionOutcome.completed,
        skippedPhaseCount: 0,
      ),
    );

    await pumpActive(false);
    expect(counting.listAllRunsCalls, 1);

    await pumpActive(true);
    expect(counting.listAllRunsCalls, 2);
  });
}

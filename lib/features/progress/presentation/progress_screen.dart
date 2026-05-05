import 'package:flutter/material.dart';

import 'package:kegel_master/features/progress/domain/session_history_entry.dart';
import 'package:kegel_master/features/progress/domain/streak_calculator.dart';
import 'package:kegel_master/features/progress/domain/training_calendar_index.dart';
import 'package:kegel_master/features/progress/presentation/day_sessions_sheet.dart';
import 'package:kegel_master/features/progress/presentation/progress_scope.dart';
import 'package:kegel_master/features/progress/presentation/training_calendar_card.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  Future<List<DateTime>>? _completedEndedAtUtcFuture;
  Future<List<SessionHistoryEntry>>? _runsFuture;
  bool _progressTabWasActive = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // StatefulShellRoute.indexedStack wraps inactive branches in
    // TickerMode(enabled: false). ModalRoute.isCurrent stays true for those
    // branches and flips when a local modal opens, so it is the wrong signal.
    final bool tabActive = TickerMode.of(context);
    if (!tabActive) {
      _progressTabWasActive = false;
      return;
    }
    if (_progressTabWasActive) return;
    _progressTabWasActive = true;
    final scope = ProgressScope.of(context);
    final streakFuture = scope.sessionHistory.completedEndedAtUtc();
    final runsFuture = scope.sessionHistory.listAllRuns();
    if (_completedEndedAtUtcFuture == null) {
      _completedEndedAtUtcFuture = streakFuture;
      _runsFuture = runsFuture;
    } else {
      setState(() {
        _completedEndedAtUtcFuture = streakFuture;
        _runsFuture = runsFuture;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Your progress',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<DateTime>>(
            future: _completedEndedAtUtcFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text('Loading streak…');
              }
              if (snapshot.hasError) {
                return const Text('Could not load streak.');
              }
              final ends = snapshot.data ?? const <DateTime>[];
              final qualifying = qualifyingLocalDatesFromEndedAt(ends);
              final n = currentStreak(
                qualifyingLocalDates: qualifying,
                now: DateTime.now(),
              );
              return Text('Current streak: $n days');
            },
          ),
          const SizedBox(height: 8),
          const Text(
            'Training calendar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<SessionHistoryEntry>>(
            future: _runsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text('Loading calendar…');
              }
              if (snapshot.hasError) {
                return const Text('Could not load calendar.');
              }
              final runs = snapshot.data ?? const <SessionHistoryEntry>[];
              final index = deriveTrainingCalendarIndex(runs);
              return TrainingCalendarCard(
                index: index,
                onOpenDay: (day) {
                  showModalBottomSheet<void>(
                    context: context,
                    showDragHandle: true,
                    isScrollControlled: true,
                    builder: (ctx) => DaySessionsSheet(
                      localDay: day,
                      runs: index.runsByLocalDay[day] ?? const [],
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 8),
          const Text('Streaks and stats — coming soon.'),
          const SizedBox(height: 32),
          const Text(
            'Achievements',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text('Badges and milestones — coming soon.'),
        ],
      ),
    );
  }
}

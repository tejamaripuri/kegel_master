import 'package:flutter/material.dart';

import 'package:kegel_master/features/progress/domain/streak_calculator.dart';
import 'package:kegel_master/features/progress/presentation/progress_scope.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  Future<List<DateTime>>? _completedEndedAtUtcFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _completedEndedAtUtcFuture ??=
        ProgressScope.of(context).sessionHistory.completedEndedAtUtc();
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

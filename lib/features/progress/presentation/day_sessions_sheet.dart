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
                  maxHeight: MediaQuery.sizeOf(context).height * 0.45,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: runs.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
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

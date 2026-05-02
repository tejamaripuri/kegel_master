import 'package:kegel_master/features/progress/domain/session_history_entry.dart';

/// Persists ended session runs.
///
/// [listAllRuns] returns rows ordered by [SessionHistoryEntry.endedAt]
/// **descending** (newest first).
abstract class SessionHistoryStore {
  Future<void> appendRun(SessionHistoryEntry run);

  Future<List<SessionHistoryEntry>> listAllRuns();

  /// [DateTime]s are UTC instants matching stored `endedAt` for completed runs.
  /// Order is unspecified.
  Future<List<DateTime>> completedEndedAtUtc();
}

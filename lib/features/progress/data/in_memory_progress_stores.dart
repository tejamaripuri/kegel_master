import 'package:kegel_master/features/progress/application/session_history_store.dart';
import 'package:kegel_master/features/progress/application/user_preferences_store.dart';
import 'package:kegel_master/features/progress/domain/session_history_entry.dart';
import 'package:kegel_master/features/progress/domain/session_outcome.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';

/// Volatile stores for platforms where Drift sqlite is not opened (e.g. web).
class InMemorySessionHistoryStore implements SessionHistoryStore {
  final List<SessionHistoryEntry> _runs = [];

  @override
  Future<void> appendRun(SessionHistoryEntry run) async {
    _runs.add(run);
  }

  @override
  Future<List<SessionHistoryEntry>> listAllRuns() async {
    final copy = List<SessionHistoryEntry>.from(_runs);
    copy.sort((a, b) => b.endedAt.compareTo(a.endedAt));
    return copy;
  }

  @override
  Future<List<DateTime>> completedEndedAtUtc() async {
    return _runs
        .where((r) => r.outcome == SessionOutcome.completed)
        .map((r) => r.endedAt)
        .toList();
  }
}

class InMemoryUserPreferencesStore implements UserPreferencesStore {
  bool _seeded = false;
  SessionConfig? _mirror;

  @override
  Future<void> ensureSeedRow() async {
    _seeded = true;
  }

  @override
  Future<SessionConfig?> readMirror() async => _mirror;

  @override
  Future<void> writeMirror(SessionConfig config) async {
    await ensureSeedRow();
    _mirror = config;
  }

  @override
  Future<void> clearMirror() async {
    _mirror = null;
  }

  @override
  Future<int> readSchemaVersion() async {
    if (!_seeded) {
      throw StateError('User preferences row missing; call ensureSeedRow first.');
    }
    return 1;
  }
}

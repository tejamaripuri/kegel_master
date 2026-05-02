import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:kegel_master/features/progress/application/session_history_store.dart';
import 'package:kegel_master/features/progress/data/drift/kegel_database.dart';
import 'package:kegel_master/features/progress/domain/session_history_entry.dart';
import 'package:kegel_master/features/progress/domain/session_outcome.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';

class DriftSessionHistoryStore implements SessionHistoryStore {
  DriftSessionHistoryStore(this._db);

  final KegelDatabase _db;

  @override
  Future<void> appendRun(SessionHistoryEntry run) async {
    await _db.into(_db.sessionRuns).insert(
          SessionRunsCompanion.insert(
            id: run.id,
            startedAtMs: run.startedAt.millisecondsSinceEpoch,
            endedAtMs: run.endedAt.millisecondsSinceEpoch,
            configJson: jsonEncode(run.configSnapshot.toJson()),
            outcome: run.outcome.name,
            skippedPhaseCount: Value(run.skippedPhaseCount),
          ),
          mode: InsertMode.insert,
        );
  }

  @override
  Future<List<SessionHistoryEntry>> listAllRuns() async {
    final rows = await (_db.select(_db.sessionRuns)
          ..orderBy([(t) => OrderingTerm(expression: t.endedAtMs, mode: OrderingMode.desc)]))
        .get();
    return rows.map(_entryFromRow).toList();
  }

  @override
  Future<List<DateTime>> completedEndedAtUtc() async {
    final rows = await (_db.select(_db.sessionRuns)
          ..where((t) => t.outcome.equals(SessionOutcome.completed.name)))
        .get();
    return rows
        .map(
          (r) => DateTime.fromMillisecondsSinceEpoch(
            r.endedAtMs,
            isUtc: true,
          ),
        )
        .toList();
  }

  SessionHistoryEntry _entryFromRow(SessionRun row) {
    final decoded = jsonDecode(row.configJson);
    final map = Map<String, Object?>.from(decoded as Map);
    return SessionHistoryEntry(
      id: row.id,
      startedAt: DateTime.fromMillisecondsSinceEpoch(
        row.startedAtMs,
        isUtc: true,
      ),
      endedAt: DateTime.fromMillisecondsSinceEpoch(
        row.endedAtMs,
        isUtc: true,
      ),
      configSnapshot: SessionConfig.fromJson(map),
      outcome: SessionOutcome.values.byName(row.outcome),
      skippedPhaseCount: row.skippedPhaseCount,
    );
  }
}

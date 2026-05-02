import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kegel_master/features/progress/data/drift/kegel_database.dart';
import 'package:kegel_master/features/progress/data/drift_session_history_store.dart';
import 'package:kegel_master/features/progress/data/drift_user_preferences_store.dart';
import 'package:kegel_master/features/progress/domain/session_history_entry.dart';
import 'package:kegel_master/features/progress/domain/session_outcome.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';

void main() {
  group('DriftSessionHistoryStore', () {
    late KegelDatabase db;
    late DriftSessionHistoryStore store;

    setUp(() {
      db = KegelDatabase(NativeDatabase.memory());
      store = DriftSessionHistoryStore(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('append, list newest first, completed endedAt', () async {
      const id = 'run-1';
      final startedAt = DateTime.utc(2026, 5, 1, 10, 0, 0);
      final endedAt = DateTime.utc(2026, 5, 1, 10, 15, 0);
      final entry = SessionHistoryEntry(
        id: id,
        startedAt: startedAt,
        endedAt: endedAt,
        configSnapshot: SessionConfig.defaults,
        outcome: SessionOutcome.completed,
        skippedPhaseCount: 0,
      );

      await store.appendRun(entry);

      final listed = await store.listAllRuns();
      expect(listed, hasLength(1));
      expect(listed.single.id, id);

      final completedEnds = await store.completedEndedAtUtc();
      expect(completedEnds, contains(endedAt));
    });
  });

  group('DriftUserPreferencesStore', () {
    late KegelDatabase db;
    late DriftUserPreferencesStore store;

    setUp(() {
      db = KegelDatabase(NativeDatabase.memory());
      store = DriftUserPreferencesStore(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('seed, schema, mirror roundtrip and clear', () async {
      await store.ensureSeedRow();
      expect(await store.readSchemaVersion(), 1);
      expect(await store.readMirror(), isNull);

      const written = SessionConfig.defaults;
      await store.writeMirror(written);
      final read = await store.readMirror();
      expect(read, isNotNull);
      expect(read!.squeezeSeconds, written.squeezeSeconds);
      expect(read.relaxSeconds, written.relaxSeconds);
      expect(read.bufferBetweenSetsSeconds, written.bufferBetweenSetsSeconds);
      expect(read.repsPerSet, written.repsPerSet);
      expect(read.targetSets, written.targetSets);

      await store.clearMirror();
      expect(await store.readMirror(), isNull);
    });
  });
}

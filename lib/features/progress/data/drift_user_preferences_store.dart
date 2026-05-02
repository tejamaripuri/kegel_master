import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:kegel_master/features/progress/application/user_preferences_store.dart';
import 'package:kegel_master/features/progress/data/drift/kegel_database.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';

class DriftUserPreferencesStore implements UserPreferencesStore {
  DriftUserPreferencesStore(this._db);

  final KegelDatabase _db;

  static const int _singletonId = 1;
  static const int _seedSchemaVersion = 1;

  @override
  Future<void> ensureSeedRow() async {
    final existing = await (_db.select(_db.userPreferenceRows)
          ..where((t) => t.id.equals(_singletonId)))
        .getSingleOrNull();
    if (existing != null) return;

    await _db.into(_db.userPreferenceRows).insert(
          UserPreferenceRowsCompanion.insert(
            id: const Value(_singletonId),
            schemaVersion: _seedSchemaVersion,
          ),
          mode: InsertMode.insert,
        );
  }

  @override
  Future<SessionConfig?> readMirror() async {
    final row = await (_db.select(_db.userPreferenceRows)
          ..where((t) => t.id.equals(_singletonId)))
        .getSingleOrNull();
    final raw = row?.sessionConfigMirrorJson;
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    return SessionConfig.fromJson(
      Map<String, Object?>.from(decoded as Map),
    );
  }

  @override
  Future<void> writeMirror(SessionConfig config) async {
    await ensureSeedRow();
    await (_db.update(_db.userPreferenceRows)
          ..where((t) => t.id.equals(_singletonId)))
        .write(
      UserPreferenceRowsCompanion(
        sessionConfigMirrorJson: Value(jsonEncode(config.toJson())),
      ),
    );
  }

  @override
  Future<void> clearMirror() async {
    await (_db.update(_db.userPreferenceRows)
          ..where((t) => t.id.equals(_singletonId)))
        .write(
      const UserPreferenceRowsCompanion(
        sessionConfigMirrorJson: Value(null),
      ),
    );
  }

  @override
  Future<int> readSchemaVersion() async {
    final row = await (_db.select(_db.userPreferenceRows)
          ..where((t) => t.id.equals(_singletonId)))
        .getSingleOrNull();
    if (row == null) {
      throw StateError('User preferences row missing; call ensureSeedRow first.');
    }
    return row.schemaVersion;
  }
}

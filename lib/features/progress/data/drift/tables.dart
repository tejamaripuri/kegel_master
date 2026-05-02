import 'package:drift/drift.dart';

class SessionRuns extends Table {
  TextColumn get id => text()();
  IntColumn get startedAtMs => integer()();
  IntColumn get endedAtMs => integer()();
  TextColumn get configJson => text()();
  TextColumn get outcome => text()();
  IntColumn get skippedPhaseCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class UserPreferenceRows extends Table {
  IntColumn get id => integer()();
  IntColumn get schemaVersion => integer()();
  TextColumn get sessionConfigMirrorJson => text().nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

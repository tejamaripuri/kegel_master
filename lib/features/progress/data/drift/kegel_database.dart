import 'package:drift/drift.dart';

import 'tables.dart';

export 'kegel_database_io.dart'
    if (dart.library.html) 'kegel_database_web.dart'
    show openKegelDatabaseConnection;

part 'kegel_database.g.dart';

@DriftDatabase(tables: [SessionRuns, UserPreferenceRows])
class KegelDatabase extends _$KegelDatabase {
  KegelDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
      );
}

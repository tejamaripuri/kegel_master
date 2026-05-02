import 'package:kegel_master/features/session/domain/session_config.dart';

abstract class UserPreferencesStore {
  /// Ensures the singleton row exists: `id = 1`, `schemaVersion = 1`, mirror null.
  Future<void> ensureSeedRow();

  Future<SessionConfig?> readMirror();

  Future<void> writeMirror(SessionConfig config);

  Future<void> clearMirror();

  Future<int> readSchemaVersion();
}

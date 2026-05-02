import 'package:drift/drift.dart';

LazyDatabase openKegelDatabaseConnection() {
  return LazyDatabase(() async {
    throw UnsupportedError(
      'Kegel progress Drift DB targets mobile/desktop (VM). '
      'Web is not wired for sqlite in this build; use conditional imports or Wasm when needed.',
    );
  });
}

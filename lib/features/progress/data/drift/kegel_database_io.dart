import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

LazyDatabase openKegelDatabaseConnection() {
  return LazyDatabase(() async {
    if (Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isMacOS ||
        Platform.isLinux ||
        Platform.isWindows) {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'kegel_progress.sqlite'));
      return NativeDatabase.createInBackground(file);
    }
    return NativeDatabase.memory();
  });
}

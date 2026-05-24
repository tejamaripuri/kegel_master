import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kegel_master/app.dart';
import 'package:kegel_master/features/onboarding/application/onboarding_gate.dart';
import 'package:kegel_master/features/onboarding/data/onboarding_persistence.dart';
import 'package:kegel_master/features/onboarding/presentation/onboarding_scope.dart';
import 'package:kegel_master/features/progress/application/session_history_store.dart';
import 'package:kegel_master/features/progress/application/user_preferences_store.dart';
import 'package:kegel_master/features/progress/data/android_sqlite_workaround.dart';
import 'package:kegel_master/features/progress/data/drift/kegel_database.dart';
import 'package:kegel_master/features/progress/data/drift_session_history_store.dart';
import 'package:kegel_master/features/progress/data/drift_user_preferences_store.dart';
import 'package:kegel_master/features/progress/data/in_memory_progress_stores.dart';
import 'package:kegel_master/features/progress/presentation/progress_scope.dart';
import 'package:kegel_master/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegel_master/core/services/shared_preferences_provider.dart';
import 'package:kegel_master/core/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
  await applyAndroidSqliteWorkaroundIfNeeded();

  late final SessionHistoryStore sessionHistory;
  late final UserPreferencesStore userPreferences;

  if (kIsWeb) {
    sessionHistory = InMemorySessionHistoryStore();
    userPreferences = InMemoryUserPreferencesStore();
    await userPreferences.ensureSeedRow();
  } else {
    final lazy = openKegelDatabaseConnection();
    final db = KegelDatabase(lazy);
    sessionHistory = DriftSessionHistoryStore(db);
    userPreferences = DriftUserPreferencesStore(db);
    await userPreferences.ensureSeedRow();
  }

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  
  final notificationService = NotificationService(FlutterLocalNotificationsPlugin());
  await notificationService.initialize();

  final OnboardingPersistence persistence =
      SharedPreferencesOnboardingPersistence(prefs);
  final OnboardingGate gate = OnboardingGate(persistence);
  await gate.load();
  final GoRouter router = createAppRouter(gate: gate);
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        notificationServiceProvider.overrideWithValue(notificationService),
        sessionHistoryStoreProvider.overrideWithValue(sessionHistory),
      ],
      child: OnboardingScope(
        gate: gate,
        child: ProgressScope(
          sessionHistory: sessionHistory,
          userPreferences: userPreferences,
          child: KegelMasterApp(router: router),
        ),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kegel_master/core/services/shared_preferences_provider.dart';
import 'package:kegel_master/core/services/notification_service.dart';
import 'package:kegel_master/core/theme/theme_mode_controller.dart';
import 'package:kegel_master/features/settings/presentation/settings_screen.dart';
import 'package:kegel_master/features/progress/application/session_history_store.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationService extends Mock implements NotificationService {}
class MockSessionHistoryStore extends Mock implements SessionHistoryStore {}

void main() {
  setUpAll(() {
    registerFallbackValue(const TimeOfDay(hour: 0, minute: 0));
  });

  group('SettingsScreen', () {
    late SharedPreferences prefs;
    late MockNotificationService mockNotificationService;
    late MockSessionHistoryStore mockSessionHistoryStore;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      mockNotificationService = MockNotificationService();
      mockSessionHistoryStore = MockSessionHistoryStore();
      
      when(() => mockNotificationService.requestPermission())
          .thenAnswer((_) async => true);
      when(() => mockNotificationService.scheduleDailyReminder(any(), todayCompleted: any(named: 'todayCompleted')))
          .thenAnswer((_) async {});
      when(() => mockNotificationService.cancelAllReminders())
          .thenAnswer((_) async {});
      when(() => mockNotificationService.isBatteryOptimizationExempted())
          .thenAnswer((_) async => true);
      when(() => mockSessionHistoryStore.completedEndedAtUtc())
          .thenAnswer((_) async => []);
    });

    Widget createWidgetUnderTest() {
      return ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          notificationServiceProvider.overrideWithValue(mockNotificationService),
          sessionHistoryStoreProvider.overrideWithValue(mockSessionHistoryStore),
        ],
        child: Consumer(
          builder: (context, ref, child) {
            final themeMode = ref.watch(themeModeControllerProvider);
            return MaterialApp(
              themeMode: themeMode,
              home: const SettingsScreen(),
            );
          },
        ),
      );
    }

    testWidgets('renders SegmentedButton with Light/Dark/System options', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(SegmentedButton<ThemeMode>), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('tapping Dark option changes the theme mode in controller', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap on Dark
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      // Verify preference was saved
      expect(prefs.getString('themeMode'), 'dark');
    });

    testWidgets('toggling Daily Reminders switch calls notification service and shows time picker', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Daily Reminders'), findsOneWidget);
      expect(find.text('Reminder Time'), findsNothing);
      
      final switchFinder = find.byType(Switch);
      expect(tester.widget<Switch>(switchFinder).value, isFalse);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(tester.widget<Switch>(switchFinder).value, isTrue);
      expect(find.text('Reminder Time'), findsOneWidget);
      expect(prefs.getBool('isReminderEnabled'), isTrue);
      verify(() => mockNotificationService.requestPermission()).called(1);
      verify(() => mockNotificationService.scheduleDailyReminder(any(), todayCompleted: any(named: 'todayCompleted'))).called(1);
      
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(tester.widget<Switch>(switchFinder).value, isFalse);
      expect(find.text('Reminder Time'), findsNothing);
      expect(prefs.getBool('isReminderEnabled'), isFalse);
      verify(() => mockNotificationService.cancelAllReminders()).called(1);
    });

    testWidgets('tapping Reminder Time shows time picker', (WidgetTester tester) async {
      await prefs.setBool('isReminderEnabled', true);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Reminder Time'), findsOneWidget);
      
      await tester.tap(find.text('Reminder Time'));
      await tester.pumpAndSettle();

      // Check for showTimePicker dialog (it's a platform dialog, usually found by its title or specific widgets)
      // In Flutter tests, it's often better to just verify the dialog appears
      expect(find.byType(TimePickerDialog), findsOneWidget);
    });
  });
}

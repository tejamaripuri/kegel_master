import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kegel_master/core/services/shared_preferences_provider.dart';
import 'package:kegel_master/core/services/notification_service.dart';
import 'package:kegel_master/features/settings/data/reminder_settings_controller.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  setUpAll(() {
    registerFallbackValue(const TimeOfDay(hour: 0, minute: 0));
  });

  group('ReminderSettingsController', () {
    late SharedPreferences prefs;
    late MockNotificationService mockNotificationService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      mockNotificationService = MockNotificationService();
      
      when(() => mockNotificationService.requestPermission())
          .thenAnswer((_) async => true);
      when(() => mockNotificationService.scheduleDailyReminder(any()))
          .thenAnswer((_) async {});
      when(() => mockNotificationService.cancelAllReminders())
          .thenAnswer((_) async {});
    });

    ProviderContainer createContainer() {
      return ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          notificationServiceProvider.overrideWithValue(mockNotificationService),
        ],
      );
    }

    test('initial state reads from SharedPreferences', () async {
      await prefs.setBool('isReminderEnabled', true);
      await prefs.setInt('reminderHour', 10);
      await prefs.setInt('reminderMinute', 30);
      
      final container = createContainer();
      final state = container.read(reminderSettingsControllerProvider);
      
      expect(state.isEnabled, isTrue);
      expect(state.reminderTime.hour, 10);
      expect(state.reminderTime.minute, 30);
    });

    test('toggling ON updates state, saves to prefs, requests permission and schedules reminder', () async {
      final container = createContainer();
      
      // Act
      await container.read(reminderSettingsControllerProvider.notifier).setReminderEnabled(true);
      
      // Assert
      final state = container.read(reminderSettingsControllerProvider);
      expect(state.isEnabled, isTrue);
      expect(prefs.getBool('isReminderEnabled'), isTrue);
      verify(() => mockNotificationService.requestPermission()).called(1);
      verify(() => mockNotificationService.scheduleDailyReminder(state.reminderTime)).called(1);
    });

    test('toggling OFF updates state, saves to prefs, and cancels reminders', () async {
      final container = createContainer();
      
      // Act
      await container.read(reminderSettingsControllerProvider.notifier).setReminderEnabled(false);
      
      // Assert
      expect(container.read(reminderSettingsControllerProvider).isEnabled, isFalse);
      expect(prefs.getBool('isReminderEnabled'), isFalse);
      verify(() => mockNotificationService.cancelAllReminders()).called(1);
    });

    test('setReminderTime updates state, saves to prefs, and reschedules if enabled', () async {
      await prefs.setBool('isReminderEnabled', true);
      final container = createContainer();
      const newTime = TimeOfDay(hour: 21, minute: 0);

      // Act
      await container.read(reminderSettingsControllerProvider.notifier).setReminderTime(newTime);

      // Assert
      final state = container.read(reminderSettingsControllerProvider);
      expect(state.reminderTime, newTime);
      expect(prefs.getInt('reminderHour'), 21);
      expect(prefs.getInt('reminderMinute'), 0);
      verify(() => mockNotificationService.scheduleDailyReminder(newTime)).called(1);
    });

    test('setReminderTime updates state and saves to prefs, but does not reschedule if disabled', () async {
      await prefs.setBool('isReminderEnabled', false);
      final container = createContainer();
      const newTime = TimeOfDay(hour: 21, minute: 0);

      // Act
      await container.read(reminderSettingsControllerProvider.notifier).setReminderTime(newTime);

      // Assert
      final state = container.read(reminderSettingsControllerProvider);
      expect(state.reminderTime, newTime);
      expect(prefs.getInt('reminderHour'), 21);
      expect(prefs.getInt('reminderMinute'), 0);
      verifyNever(() => mockNotificationService.scheduleDailyReminder(any()));
    });
  });
}

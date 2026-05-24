import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegel_master/core/services/shared_preferences_provider.dart';
import 'package:kegel_master/core/services/notification_service.dart';

const String _isReminderEnabledKey = 'isReminderEnabled';
const String _reminderHourKey = 'reminderHour';
const String _reminderMinuteKey = 'reminderMinute';

class ReminderSettings {
  final bool isEnabled;
  final TimeOfDay reminderTime;

  const ReminderSettings({
    required this.isEnabled,
    required this.reminderTime,
  });

  ReminderSettings copyWith({
    bool? isEnabled,
    TimeOfDay? reminderTime,
  }) {
    return ReminderSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}

class ReminderSettingsController extends Notifier<ReminderSettings> {
  @override
  ReminderSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final isEnabled = prefs.getBool(_isReminderEnabledKey) ?? false;
    final hour = prefs.getInt(_reminderHourKey) ?? 8;
    final minute = prefs.getInt(_reminderMinuteKey) ?? 0;
    
    return ReminderSettings(
      isEnabled: isEnabled,
      reminderTime: TimeOfDay(hour: hour, minute: minute),
    );
  }

  Future<void> setReminderEnabled(bool enabled) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_isReminderEnabledKey, enabled);
    state = state.copyWith(isEnabled: enabled);

    final notificationService = ref.read(notificationServiceProvider);
    if (enabled) {
      final granted = await notificationService.requestPermission();
      if (granted) {
        await notificationService.scheduleDailyReminder(state.reminderTime);
      } else {
        // Permission denied — revert toggle so the UI reflects reality.
        await prefs.setBool(_isReminderEnabledKey, false);
        state = state.copyWith(isEnabled: false);
      }
    } else {
      await notificationService.cancelAllReminders();
    }
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(_reminderHourKey, time.hour);
    await prefs.setInt(_reminderMinuteKey, time.minute);
    state = state.copyWith(reminderTime: time);

    if (state.isEnabled) {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.scheduleDailyReminder(time);
    }
  }
}

final reminderSettingsControllerProvider =
    NotifierProvider<ReminderSettingsController, ReminderSettings>(() {
      return ReminderSettingsController();
    });

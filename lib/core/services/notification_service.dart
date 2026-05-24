import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// Always override this provider in main() and in tests via overrideWithValue.
final notificationServiceProvider = Provider<NotificationService>((_) {
  throw UnimplementedError(
    'notificationServiceProvider must be overridden via overrideWithValue.',
  );
});

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;

  NotificationService(this._plugin);

  /// Shared notification details used for all reminders.
  static const _reminderDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'v3_priority_channel',
      'Reminders',
      channelDescription: 'Priority reminders for exercises',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
    ),
    iOS: DarwinNotificationDetails(),
  );

  Future<void> initialize() async {
    const androidInitialize = AndroidInitializationSettings(
      '@drawable/ic_notification',
    );
    const iosInitialize = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initializationsSettings = InitializationSettings(
      android: androidInitialize,
      iOS: iosInitialize,
    );
    await _plugin.initialize(initializationsSettings);
  }

  Future<bool> isBatteryOptimizationExempted() async {
    if (!Platform.isAndroid) return true;
    try {
      final result = await const MethodChannel(
        'kegel_master/battery',
      ).invokeMethod<bool>('isIgnoringBatteryOptimizations');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> requestBatteryOptimizationExemption() async {
    if (!Platform.isAndroid) return;
    try {
      await const MethodChannel(
        'kegel_master/battery',
      ).invokeMethod('requestIgnoreBatteryOptimizations');
    } catch (e) {
      debugPrint('Battery exemption request failed: $e');
    }
  }

  Future<bool> requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosImpl = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (iosImpl != null) {
        final granted = await iosImpl.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidImpl != null) {
        final notificationsGranted = await androidImpl
            .requestNotificationsPermission();
        final exactAlarmsGranted = await androidImpl
            .requestExactAlarmsPermission();
        return (notificationsGranted ?? false) && (exactAlarmsGranted ?? true);
      }
    }
    return false;
  }

  tz.TZDateTime _nextInstanceOfWeekdayAndTime(tz.TZDateTime now, int weekday, TimeOfDay time) {
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }
    return scheduledDate;
  }

  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    await cancelAllReminders();

    final now = tz.TZDateTime.now(tz.local);

    for (int weekday = 1; weekday <= 7; weekday++) {
      final scheduledDate = _nextInstanceOfWeekdayAndTime(now, weekday, time);

      await _plugin.zonedSchedule(
        10 + weekday, // notification ids 11 to 17
        'Kegel Reminder',
        'Time to do your exercises!',
        scheduledDate,
        _reminderDetails,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  /// Cancels today's reminder and reschedules it for next week.
  ///
  /// The caller is responsible for checking whether reminders are enabled
  /// before invoking this method. [time] is the configured reminder time
  /// (from [ReminderSettings.reminderTime]).
  Future<void> cancelTodayReminder(TimeOfDay time) async {
    final now = tz.TZDateTime.now(tz.local);
    final int todayWeekday = now.weekday;

    // Cancel today's notification.
    await _plugin.cancel(10 + todayWeekday);

    // Reschedule it to next week.
    var nextWeekDate = _nextInstanceOfWeekdayAndTime(now, todayWeekday, time);
    if (nextWeekDate.year == now.year &&
        nextWeekDate.month == now.month &&
        nextWeekDate.day == now.day) {
      nextWeekDate = nextWeekDate.add(const Duration(days: 7));
    }

    await _plugin.zonedSchedule(
      10 + todayWeekday,
      'Kegel Reminder',
      'Time to do your exercises!',
      nextWeekDate,
      _reminderDetails,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> cancelAllReminders() async {
    await _plugin.cancelAll();
  }
}

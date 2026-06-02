import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Always override this provider in main() and in tests via overrideWithValue.
final notificationServiceProvider = Provider<NotificationService>((_) {
  throw UnimplementedError(
    'notificationServiceProvider must be overridden via overrideWithValue.',
  );
});

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;
  void Function()? _onTapCallback;
  bool _pendingTap = false;

  NotificationService(this._plugin);

  void registerTapHandler(void Function() callback) {
    _onTapCallback = callback;
    if (_pendingTap) {
      _pendingTap = false;
      callback();
    }
  }

  static const int snoozeReminderId = 99;

  /// Shared notification details used for all reminders.
  static const _reminderDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'v3_priority_channel',
      'Reminders',
      channelDescription: 'Priority reminders for exercises',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'snooze_action',
          'Snooze (1 hour)',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    ),
    iOS: DarwinNotificationDetails(
      categoryIdentifier: 'reminder_category',
    ),
  );

  /// Clears any pending snooze, optionally cancels [sourceNotificationId], then schedules one shot +1 hour.
  static Future<void> applySnoozeWithPlugin(
    FlutterLocalNotificationsPlugin plugin, {
    int? sourceNotificationId,
    DateTime? now,
  }) async {
    await plugin.cancel(snoozeReminderId);
    if (sourceNotificationId != null) {
      await plugin.cancel(sourceNotificationId);
    }
    final currentDateTime = now ?? DateTime.now();
    final tzNow = tz.TZDateTime.from(currentDateTime, tz.local);
    final snoozeTime = tzNow.add(const Duration(hours: 1));

    await plugin.zonedSchedule(
      snoozeReminderId,
      'Kegel Reminder',
      'Time to do your exercises!',
      snoozeTime,
      _reminderDetails,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _applySnooze({int? sourceNotificationId, DateTime? now}) =>
      applySnoozeWithPlugin(
        _plugin,
        sourceNotificationId: sourceNotificationId,
        now: now,
      );

  Future<void> initialize() async {
    const androidInitialize = AndroidInitializationSettings(
      '@drawable/ic_notification',
    );
    final iosInitialize = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      notificationCategories: [
        DarwinNotificationCategory(
          'reminder_category',
          actions: [
            DarwinNotificationAction.plain(
              'snooze_action',
              'Snooze (1 hour)',
            ),
          ],
        ),
      ],
    );
    final initializationsSettings = InitializationSettings(
      android: androidInitialize,
      iOS: iosInitialize,
    );
    await _plugin.initialize(
      initializationsSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        if (details.actionId == 'snooze_action') {
          unawaited(_applySnooze(sourceNotificationId: details.id));
        } else {
          if (_onTapCallback != null) {
            _onTapCallback!();
          } else {
            _pendingTap = true;
          }
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    try {
      final launchDetails = await _plugin.getNotificationAppLaunchDetails();
      if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
        final details = launchDetails.notificationResponse;
        if (details != null && details.actionId == 'snooze_action') {
          await _applySnooze(sourceNotificationId: details.id);
        } else {
          if (_onTapCallback != null) {
            _onTapCallback!();
          } else {
            _pendingTap = true;
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking launch details: $e');
    }
  }

  Future<void> snoozeReminder({DateTime? now, int? sourceNotificationId}) =>
      applySnoozeWithPlugin(
        _plugin,
        sourceNotificationId: sourceNotificationId,
        now: now,
      );

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

  Future<void> scheduleDailyReminder(TimeOfDay time, {bool todayCompleted = false, DateTime? now}) async {
    for (int weekday = 1; weekday <= 7; weekday++) {
      await _plugin.cancel(10 + weekday);
    }

    final tzNow = tz.TZDateTime.from(now ?? DateTime.now(), tz.local);
    final int todayWeekday = tzNow.weekday;

    for (int weekday = 1; weekday <= 7; weekday++) {
      final scheduledDate = _nextInstanceOfWeekdayAndTime(tzNow, weekday, time);

      if (weekday == todayWeekday && todayCompleted) {
        var nextWeekDate = scheduledDate;
        if (nextWeekDate.year == tzNow.year &&
            nextWeekDate.month == tzNow.month &&
            nextWeekDate.day == tzNow.day) {
          nextWeekDate = nextWeekDate.add(const Duration(days: 7));
        }

        await _plugin.zonedSchedule(
          10 + weekday,
          'Kegel Reminder',
          'Time to do your exercises!',
          nextWeekDate,
          _reminderDetails,
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } else {
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
  }

  /// Cancels today's reminder and reschedules it for next week.
  ///
  /// The caller is responsible for checking whether reminders are enabled
  /// before invoking this method. [time] is the configured reminder time
  /// (from [ReminderSettings.reminderTime]).
  Future<void> cancelTodayReminder(TimeOfDay time, {DateTime? now}) async {
    await scheduleDailyReminder(time, todayCompleted: true, now: now);
    await _plugin.cancel(snoozeReminderId);
  }

  Future<void> cancelAllReminders() async {
    await _plugin.cancelAll();
  }
}

@visibleForTesting
FlutterLocalNotificationsPlugin? debugNotificationPluginOverride;

@pragma('vm:entry-point')
Future<void> notificationTapBackground(NotificationResponse details) async {
  if (details.actionId == 'snooze_action') {
    WidgetsFlutterBinding.ensureInitialized();
    tz_data.initializeTimeZones();
    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
    } catch (_) {}

    final plugin = debugNotificationPluginOverride ?? FlutterLocalNotificationsPlugin();
    await NotificationService.applySnoozeWithPlugin(
      plugin,
      sourceNotificationId: details.id,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:clock/clock.dart';
import 'package:kegel_master/core/services/notification_service.dart';

class MockFlutterLocalNotificationsPlugin implements FlutterLocalNotificationsPlugin {
  bool requestPermissionCalled = false;
  bool zonedScheduleCalled = false;
  bool initializeCalled = false;
  bool cancelCalled = false;
  int? lastCanceledId;
  final List<int> canceledIds = [];
  NotificationAppLaunchDetails? testAppLaunchDetails;
  void Function(NotificationResponse)? onNotificationResponse;
  void Function(NotificationResponse)? onNotificationBackgroundResponse;

  int? lastScheduledId;
  String? lastScheduledTitle;
  String? lastScheduledBody;
  dynamic lastScheduledDate;
  dynamic lastMatchDateTimeComponents;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #resolvePlatformSpecificImplementation) {
      if (invocation.typeArguments.first == AndroidFlutterLocalNotificationsPlugin) {
        return MockAndroidFlutterLocalNotificationsPlugin(this);
      } else if (invocation.typeArguments.first == IOSFlutterLocalNotificationsPlugin) {
        return MockIOSFlutterLocalNotificationsPlugin(this);
      }
      return null;
    } else if (invocation.memberName == #zonedSchedule) {
      zonedScheduleCalled = true;
      lastScheduledId = invocation.positionalArguments[0] as int;
      lastScheduledTitle = invocation.positionalArguments[1] as String?;
      lastScheduledBody = invocation.positionalArguments[2] as String?;
      lastScheduledDate = invocation.positionalArguments[3];
      lastMatchDateTimeComponents = invocation.namedArguments[#matchDateTimeComponents];
      return Future.value();
    } else if (invocation.memberName == #cancel) {
      cancelCalled = true;
      final id = invocation.positionalArguments[0] as int;
      lastCanceledId = id;
      canceledIds.add(id);
      return Future.value();
    } else if (invocation.memberName == #cancelAll) {
      return Future.value();
    } else if (invocation.memberName == #initialize) {
      initializeCalled = true;
      onNotificationResponse = invocation.namedArguments[#onDidReceiveNotificationResponse] as void Function(NotificationResponse)?;
      onNotificationBackgroundResponse = invocation.namedArguments[#onDidReceiveBackgroundNotificationResponse] as void Function(NotificationResponse)?;
      return Future.value(true);
    } else if (invocation.memberName == #getNotificationAppLaunchDetails) {
      return Future.value(testAppLaunchDetails);
    }
    return super.noSuchMethod(invocation);
  }
}

class MockAndroidFlutterLocalNotificationsPlugin implements AndroidFlutterLocalNotificationsPlugin {
  final MockFlutterLocalNotificationsPlugin parent;
  MockAndroidFlutterLocalNotificationsPlugin(this.parent);

  @override
  Future<bool?> requestNotificationsPermission() async {
    parent.requestPermissionCalled = true;
    return true;
  }

  @override
  Future<bool?> requestExactAlarmsPermission() async {
    return true;
  }
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockIOSFlutterLocalNotificationsPlugin implements IOSFlutterLocalNotificationsPlugin {
  final MockFlutterLocalNotificationsPlugin parent;
  MockIOSFlutterLocalNotificationsPlugin(this.parent);

  @override
  Future<bool?> requestPermissions({bool? sound, bool? alert, bool? badge, bool? provisional, bool? critical}) async {
    parent.requestPermissionCalled = true;
    return true;
  }
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('NotificationService', () {
    late MockFlutterLocalNotificationsPlugin mockPlugin;
    late NotificationService notificationService;

    setUp(() {
      tz_data.initializeTimeZones();
      mockPlugin = MockFlutterLocalNotificationsPlugin();
      notificationService = NotificationService(mockPlugin);
    });
    
    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      debugNotificationPluginOverride = null;
    });

    test('requestPermission requests OS permissions on iOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      // Act
      final result = await notificationService.requestPermission();

      // Assert
      expect(result, isTrue);
      expect(mockPlugin.requestPermissionCalled, isTrue);
    });
    
    test('requestPermission requests OS permissions on Android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      // Act
      final result = await notificationService.requestPermission();

      // Assert
      expect(result, isTrue);
      expect(mockPlugin.requestPermissionCalled, isTrue);
    });
    
    test('scheduleDailyReminder schedules a notification', () async {
      // Act
      await notificationService.scheduleDailyReminder(const TimeOfDay(hour: 8, minute: 0));

      // Assert
      expect(mockPlugin.zonedScheduleCalled, isTrue);
    });

    test('cancelTodayReminder cancels and reschedules for next week', () async {
      // Act — caller is responsible for checking isEnabled before calling.
      await notificationService.cancelTodayReminder(
        const TimeOfDay(hour: 8, minute: 0),
      );

      // Assert — the rescheduled next-week notification was zonedScheduled.
      expect(mockPlugin.zonedScheduleCalled, isTrue);
    });

    test('cancelTodayReminder with time in future schedules for next week', () async {
      // Sunday May 24, 2026 15:30. Sunday is weekday 7.
      final fixedTime = DateTime.utc(2026, 5, 24, 15, 30);
      await withClock(Clock.fixed(fixedTime), () async {
        await notificationService.cancelTodayReminder(
          const TimeOfDay(hour: 15, minute: 35),
          now: fixedTime,
        );

        expect(mockPlugin.zonedScheduleCalled, isTrue);
        expect(mockPlugin.lastScheduledDate, isNotNull);
        // It should be scheduled for next Sunday, which is May 31, 2026.
        final date = mockPlugin.lastScheduledDate as DateTime;
        expect(date.year, equals(2026));
        expect(date.month, equals(5));
        expect(date.day, equals(31));
        expect(date.hour, equals(15));
        expect(date.minute, equals(35));
      });
    });

    test('cancelTodayReminder with time in past schedules for next week', () async {
      // Sunday May 24, 2026 15:30. Sunday is weekday 7.
      final fixedTime = DateTime.utc(2026, 5, 24, 15, 30);
      await withClock(Clock.fixed(fixedTime), () async {
        await notificationService.cancelTodayReminder(
          const TimeOfDay(hour: 15, minute: 25),
          now: fixedTime,
        );

        expect(mockPlugin.zonedScheduleCalled, isTrue);
        expect(mockPlugin.lastScheduledDate, isNotNull);
        // It should be scheduled for next Sunday, which is May 31, 2026.
        final date = mockPlugin.lastScheduledDate as DateTime;
        expect(date.year, equals(2026));
        expect(date.month, equals(5));
        expect(date.day, equals(31));
        expect(date.hour, equals(15));
        expect(date.minute, equals(25));
      });
    });

    test('initialize registers callback and processes pending tap if launched from notification', () async {
      mockPlugin.testAppLaunchDetails = const NotificationAppLaunchDetails(
        true,
        notificationResponse: NotificationResponse(
          notificationResponseType: NotificationResponseType.selectedNotification,
          payload: 'test_payload',
        ),
      );

      await notificationService.initialize();

      expect(mockPlugin.initializeCalled, isTrue);

      bool tapCallbackCalled = false;
      notificationService.registerTapHandler(() {
        tapCallbackCalled = true;
      });

      expect(tapCallbackCalled, isTrue);
    });

    test('active app tap callback is triggered immediately when notification is clicked', () async {
      await notificationService.initialize();

      bool tapCallbackCalled = false;
      notificationService.registerTapHandler(() {
        tapCallbackCalled = true;
      });

      expect(tapCallbackCalled, isFalse);

      mockPlugin.onNotificationResponse?.call(const NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotification,
        payload: 'test_payload',
      ));

      expect(tapCallbackCalled, isTrue);
    });

    test('snoozeReminder schedules a notification 1 hour in the future with ID 99', () async {
      final fixedTime = DateTime.utc(2026, 5, 24, 15, 30);
      await withClock(Clock.fixed(fixedTime), () async {
        await notificationService.snoozeReminder(now: fixedTime);

        expect(mockPlugin.zonedScheduleCalled, isTrue);
        expect(mockPlugin.lastScheduledId, equals(99));
        expect(mockPlugin.lastScheduledTitle, equals('Kegel Reminder'));
        expect(mockPlugin.lastScheduledBody, equals('Time to do your exercises!'));
        
        final scheduledDate = mockPlugin.lastScheduledDate as DateTime;
        expect(scheduledDate.year, equals(2026));
        expect(scheduledDate.month, equals(5));
        expect(scheduledDate.day, equals(24));
        expect(scheduledDate.hour, equals(16));
        expect(scheduledDate.minute, equals(30));
      });
    });

    test('initialize registers background notification callback', () async {
      await notificationService.initialize();

      expect(mockPlugin.onNotificationBackgroundResponse, isNotNull);
      expect(mockPlugin.onNotificationBackgroundResponse, equals(notificationTapBackground));
    });

    test('notificationTapBackground background callback schedules snooze and cancels active reminder', () async {
      debugNotificationPluginOverride = mockPlugin;
      
      await notificationTapBackground(const NotificationResponse(
        id: 12,
        notificationResponseType: NotificationResponseType.selectedNotification,
        actionId: 'snooze_action',
        payload: 'test_payload',
      ));

      expect(mockPlugin.cancelCalled, isTrue);
      expect(mockPlugin.lastCanceledId, equals(12));
      expect(mockPlugin.zonedScheduleCalled, isTrue);
      expect(mockPlugin.lastScheduledId, equals(99));
    });

    test('cancelTodayReminder cancels snooze notification ID 99', () async {
      await notificationService.cancelTodayReminder(
        const TimeOfDay(hour: 8, minute: 0),
        now: DateTime.utc(2026, 5, 24, 15, 30),
      );

      expect(mockPlugin.cancelCalled, isTrue);
      expect(mockPlugin.lastCanceledId, equals(99));
    });

    test('scheduleDailyReminder does not cancel snooze reminder', () async {
      await notificationService.snoozeReminder(now: DateTime.utc(2026, 5, 24, 15, 30));
      // Reset tracking
      mockPlugin.cancelCalled = false;
      mockPlugin.canceledIds.clear();

      await notificationService.scheduleDailyReminder(const TimeOfDay(hour: 8, minute: 0));

      expect(mockPlugin.canceledIds, isNot(contains(99)));
    });
  });
}

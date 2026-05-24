import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzData;
import 'package:kegel_master/core/services/notification_service.dart';

class MockFlutterLocalNotificationsPlugin implements FlutterLocalNotificationsPlugin {
  bool requestPermissionCalled = false;
  bool zonedScheduleCalled = false;

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
      return Future.value();
    } else if (invocation.memberName == #cancel || invocation.memberName == #cancelAll) {
      return Future.value();
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
      tzData.initializeTimeZones();
      mockPlugin = MockFlutterLocalNotificationsPlugin();
      notificationService = NotificationService(mockPlugin);
    });
    
    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
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
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegel_master/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:kegel_master/core/theme/app_theme.dart';
import 'package:kegel_master/core/theme/theme_mode_controller.dart';
import 'package:kegel_master/core/services/notification_service.dart';
import 'package:kegel_master/features/settings/data/reminder_settings_controller.dart';
import 'package:kegel_master/features/progress/application/session_history_store.dart';

class KegelMasterApp extends ConsumerStatefulWidget {
  const KegelMasterApp({super.key, required this.router});

  final GoRouter router;

  @override
  ConsumerState<KegelMasterApp> createState() => _KegelMasterAppState();
}

class _KegelMasterAppState extends ConsumerState<KegelMasterApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.read(notificationServiceProvider).registerTapHandler(() {
      widget.router.go('/home');
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshRemindersOnStartup();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshRemindersOnStartup();
    }
  }

  Future<void> _refreshRemindersOnStartup() async {
    try {
      final reminderSettings = ref.read(reminderSettingsControllerProvider);
      if (reminderSettings.isEnabled) {
        final sessionHistory = ref.read(sessionHistoryStoreProvider);
        final completedTimes = await sessionHistory.completedEndedAtUtc();
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final completedToday = completedTimes.any((utcTime) {
          final local = utcTime.toLocal();
          return local.year == today.year &&
              local.month == today.month &&
              local.day == today.day;
        });

        await ref
            .read(notificationServiceProvider)
            .scheduleDailyReminder(
              reminderSettings.reminderTime,
              todayCompleted: completedToday,
            );
      }
    } catch (e) {
      debugPrint('Failed to refresh reminders on startup: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeControllerProvider);

    return MaterialApp.router(
      title: 'Kegel Master',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: widget.router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

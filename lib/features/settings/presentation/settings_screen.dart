import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kegel_master/features/onboarding/presentation/onboarding_scope.dart';
import 'package:kegel_master/core/theme/theme_mode_controller.dart';
import 'package:kegel_master/features/settings/data/reminder_settings_controller.dart';
import 'package:kegel_master/core/services/notification_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _onResetPressed(BuildContext context) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset onboarding?'),
          content: const Text(
            'This clears your saved answers and safety state. You will see the disclaimer and questions again.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
    if (ok == true && context.mounted) {
      await OnboardingScope.of(context).resetAll();
      if (context.mounted) {
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appearance',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto),
                      label: Text('System'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.brightness_5),
                      label: Text('Light'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.brightness_4),
                      label: Text('Dark'),
                    ),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (Set<ThemeMode> newSelection) {
                    ref
                        .read(themeModeControllerProvider.notifier)
                        .setThemeMode(newSelection.first);
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          Consumer(
            builder: (context, ref, child) {
              final reminderState = ref.watch(
                reminderSettingsControllerProvider,
              );
              final notifService = ref.read(notificationServiceProvider);
              return Column(
                children: [
                  SwitchListTile(
                    title: const Text('Daily Reminders'),
                    subtitle: const Text(
                      'Receive a daily nudge to do your exercises',
                    ),
                    value: reminderState.isEnabled,
                    onChanged: (bool value) {
                      ref
                          .read(reminderSettingsControllerProvider.notifier)
                          .setReminderEnabled(value);
                    },
                  ),
                  if (reminderState.isEnabled)
                    FutureBuilder<bool>(
                      future: notifService.isBatteryOptimizationExempted(),
                      builder: (context, snapshot) {
                        final isExempted = snapshot.data ?? true;
                        if (!isExempted) {
                          return MaterialBanner(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.errorContainer,
                            leading: Icon(
                              Icons.battery_alert,
                              color: Theme.of(
                                context,
                              ).colorScheme.onErrorContainer,
                            ),
                            content: Text(
                              'Battery optimization is blocking your reminders. Tap to fix.',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => notifService
                                    .requestBatteryOptimizationExemption(),
                                child: const Text('Fix Now'),
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  if (reminderState.isEnabled)
                    ListTile(
                      title: const Text('Reminder Time'),
                      subtitle: Text(
                        reminderState.reminderTime.format(context),
                      ),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: reminderState.reminderTime,
                        );
                        if (picked != null) {
                          ref
                              .read(reminderSettingsControllerProvider.notifier)
                              .setReminderTime(picked);
                        }
                      },
                    ),
                ],
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Reset onboarding'),
            subtitle: const Text('Clear profile and run setup again'),
            onTap: () => _onResetPressed(context),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kegel_master/features/onboarding/presentation/onboarding_scope.dart';

class SettingsScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: <Widget>[
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kegel_master/features/onboarding/presentation/onboarding_scope.dart';
import 'package:kegel_master/features/progress/domain/effective_session_config.dart';
import 'package:kegel_master/features/progress/presentation/progress_scope.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gate = OnboardingScope.of(context);
    final prefs = ProgressScope.of(context).userPreferences;

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Start a guided session when you are ready.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            FutureBuilder<SessionConfig?>(
              future: prefs.readMirror(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 48,
                    width: 48,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snap.hasError) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Could not load session preferences.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                final SessionConfig config = resolveEffectiveSessionConfig(
                  mirror: snap.data,
                  onboardingComplete: gate.snapshot.onboardingComplete,
                  profile: gate.snapshot.profile,
                );
                return FilledButton(
                  onPressed: () => context.push('/session', extra: config),
                  child: const Text('Start session'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:kegel_master/features/onboarding/presentation/onboarding_scope.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool catheter =
        OnboardingScope.of(context).snapshot.catheterActive;
    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (catheter)
            ColoredBox(
              color: Theme.of(context).colorScheme.errorContainer,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Pelvic floor exercises are suspended while you use a catheter. '
                  'Educational content only — follow your care team.',
                ),
              ),
            ),
          const Expanded(
            child: Center(
              child: Text('Guides and techniques — coming soon.'),
            ),
          ),
        ],
      ),
    );
  }
}

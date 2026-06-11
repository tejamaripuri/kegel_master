import 'package:flutter/material.dart';
import 'package:kegel_master/features/learn/data/learn_release_bundle.dart';
import 'package:kegel_master/features/learn/domain/learn_profile_signals.dart';
import 'package:kegel_master/features/onboarding/presentation/onboarding_scope.dart';
import 'package:kegel_master/l10n/app_localizations.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final gate = OnboardingScope.of(context);
    final LearnProfileSignals? signals = gate.learnProfileSignalsOrNull();
    final bool catheter =
        signals?.hasActiveCatheter ?? gate.snapshot.catheterActive;
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.learnAppBarTitle)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (catheter)
            ColoredBox(
              color: colors.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  l10n.learnCatheterBannerBody,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onErrorContainer,
                  ),
                ),
              ),
            ),
          Material(
            color: colors.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                l10n.learnShellDisclaimer,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: <Widget>[
                Text(
                  l10n.learnFoundationSectionTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...learnFoundationItemsV1.map(
                  (LearnFoundationId id) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ExpansionTile(
                      title: Text(id.title(l10n)),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(id.body(l10n)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

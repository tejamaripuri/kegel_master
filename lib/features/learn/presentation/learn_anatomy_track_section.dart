import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegel_master/features/learn/application/learn_anatomy_track_controller.dart';
import 'package:kegel_master/features/learn/data/learn_release_bundle.dart';
import 'package:kegel_master/features/learn/domain/learn_effective_anatomy_track.dart';
import 'package:kegel_master/features/learn/domain/learn_profile_signals.dart';
import 'package:kegel_master/features/onboarding/presentation/onboarding_scope.dart';
import 'package:kegel_master/l10n/app_localizations.dart';

class LearnAnatomyTrackSection extends ConsumerWidget {
  const LearnAnatomyTrackSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final LearnProfileSignals? signals =
        OnboardingScope.of(context).learnProfileSignalsOrNull();
    final AnatomyTrack? explicitTrack =
        ref.watch(learnAnatomyTrackControllerProvider);
    final AnatomyTrack? effectiveTrack = resolveEffectiveAnatomyTrack(
      suggestedAnatomyTrack: signals?.suggestedAnatomyTrack,
      explicitAnatomyTrack: explicitTrack,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 24),
        Text(
          l10n.learnAnatomySectionTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.learnAnatomySectionIntro,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: learnAnatomyTracksV1.map((AnatomyTrack track) {
            final bool selected = effectiveTrack == track;
            return FilterChip(
              label: Text(track.label(l10n)),
              selected: selected,
              onSelected: (_) {
                ref.read(learnAnatomyTrackControllerProvider.notifier).setTrack(
                      track,
                    );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        if (effectiveTrack == null)
          Text(
            l10n.learnAnatomyPromptSelectTrack,
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else ...<Widget>[
          Text(
            effectiveTrack.howToBody(l10n),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: ExpansionTile(
              title: Text(l10n.learnAnatomyPrivacyExpansionTitle),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      effectiveTrack.privacyExpansionBody(l10n),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

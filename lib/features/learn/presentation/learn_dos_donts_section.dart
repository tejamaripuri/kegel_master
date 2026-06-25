import 'package:flutter/material.dart';
import 'package:kegel_master/features/learn/data/learn_release_bundle.dart';
import 'package:kegel_master/l10n/app_localizations.dart';

class LearnDosDontsSection extends StatelessWidget {
  const LearnDosDontsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Iterable<LearnDosDontsEntry> dos = learnDosDontsItemsV1.where(
      (LearnDosDontsEntry e) => e.polarity == LearnDosDontsPolarity.dos,
    );
    final Iterable<LearnDosDontsEntry> donts = learnDosDontsItemsV1.where(
      (LearnDosDontsEntry e) => e.polarity == LearnDosDontsPolarity.dont,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 24),
        Text(
          l10n.learnDosDontsSectionTitle,
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.learnDosDontsSectionIntro,
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.learnDosDontsDoSubgroupTitle,
          style: textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        ...dos.map(
          (LearnDosDontsEntry entry) => _DosDontsRow(
            text: entry.id.text(l10n),
            icon: Icons.check_circle_outline,
            iconColor: colors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.learnDosDontsDontSubgroupTitle,
          style: textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        ...donts.map(
          (LearnDosDontsEntry entry) => _DosDontsRow(
            text: entry.id.text(l10n),
            icon: Icons.cancel_outlined,
            iconColor: colors.error,
          ),
        ),
      ],
    );
  }
}

class _DosDontsRow extends StatelessWidget {
  const _DosDontsRow({
    required this.text,
    required this.icon,
    required this.iconColor,
  });

  final String text;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

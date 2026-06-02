import 'package:kegel_master/l10n/app_localizations.dart';

/// Learn release bundle v1 — foundation slice only (structure + order; copy in ARB).
const String learnReleaseBundleVersion = '1';

enum LearnFoundationId { whatPelvicFloor, coordination, progress, careTeam }

const List<LearnFoundationId> learnFoundationItemsV1 = <LearnFoundationId>[
  LearnFoundationId.whatPelvicFloor,
  LearnFoundationId.coordination,
  LearnFoundationId.progress,
  LearnFoundationId.careTeam,
];

extension LearnFoundationIdL10n on LearnFoundationId {
  String title(AppLocalizations l10n) {
    switch (this) {
      case LearnFoundationId.whatPelvicFloor:
        return l10n.learnFoundationWhatPelvicFloorTitle;
      case LearnFoundationId.coordination:
        return l10n.learnFoundationCoordinationTitle;
      case LearnFoundationId.progress:
        return l10n.learnFoundationProgressTitle;
      case LearnFoundationId.careTeam:
        return l10n.learnFoundationCareTeamTitle;
    }
  }

  String body(AppLocalizations l10n) {
    switch (this) {
      case LearnFoundationId.whatPelvicFloor:
        return l10n.learnFoundationWhatPelvicFloorBody;
      case LearnFoundationId.coordination:
        return l10n.learnFoundationCoordinationBody;
      case LearnFoundationId.progress:
        return l10n.learnFoundationProgressBody;
      case LearnFoundationId.careTeam:
        return l10n.learnFoundationCareTeamBody;
    }
  }
}

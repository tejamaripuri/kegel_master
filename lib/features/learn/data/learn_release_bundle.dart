import 'package:kegel_master/features/learn/domain/learn_profile_signals.dart';
import 'package:kegel_master/l10n/app_localizations.dart';

/// Learn release bundle v1 — structure + order; copy in ARB.
const String learnReleaseBundleVersion = '1';

const List<AnatomyTrack> learnAnatomyTracksV1 = <AnatomyTrack>[
  AnatomyTrack.maleTypical,
  AnatomyTrack.femaleTypical,
];

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

extension AnatomyTrackL10n on AnatomyTrack {
  String label(AppLocalizations l10n) {
    switch (this) {
      case AnatomyTrack.maleTypical:
        return l10n.learnAnatomyTrackMaleTypicalLabel;
      case AnatomyTrack.femaleTypical:
        return l10n.learnAnatomyTrackFemaleTypicalLabel;
    }
  }

  String howToBody(AppLocalizations l10n) {
    switch (this) {
      case AnatomyTrack.maleTypical:
        return l10n.learnAnatomyMaleTypicalBody;
      case AnatomyTrack.femaleTypical:
        return l10n.learnAnatomyFemaleTypicalBody;
    }
  }

  String privacyExpansionBody(AppLocalizations l10n) {
    switch (this) {
      case AnatomyTrack.maleTypical:
        return l10n.learnAnatomyMaleTypicalPrivacyBody;
      case AnatomyTrack.femaleTypical:
        return l10n.learnAnatomyFemaleTypicalPrivacyBody;
    }
  }
}

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

enum LearnDosDontsPolarity { dos, dont }

enum LearnDosDontsId {
  releaseBetweenReps,
  breatheNormally,
  startShortSets,
  stopOnFlare,
  noPainThrough,
  noCompensate,
  noCatheterTrain,
  noSubstituteClinician,
}

class LearnDosDontsEntry {
  const LearnDosDontsEntry({
    required this.id,
    required this.polarity,
  });

  final LearnDosDontsId id;
  final LearnDosDontsPolarity polarity;
}

const List<LearnDosDontsEntry> learnDosDontsItemsV1 = <LearnDosDontsEntry>[
  LearnDosDontsEntry(
    id: LearnDosDontsId.releaseBetweenReps,
    polarity: LearnDosDontsPolarity.dos,
  ),
  LearnDosDontsEntry(
    id: LearnDosDontsId.breatheNormally,
    polarity: LearnDosDontsPolarity.dos,
  ),
  LearnDosDontsEntry(
    id: LearnDosDontsId.startShortSets,
    polarity: LearnDosDontsPolarity.dos,
  ),
  LearnDosDontsEntry(
    id: LearnDosDontsId.stopOnFlare,
    polarity: LearnDosDontsPolarity.dos,
  ),
  LearnDosDontsEntry(
    id: LearnDosDontsId.noPainThrough,
    polarity: LearnDosDontsPolarity.dont,
  ),
  LearnDosDontsEntry(
    id: LearnDosDontsId.noCompensate,
    polarity: LearnDosDontsPolarity.dont,
  ),
  LearnDosDontsEntry(
    id: LearnDosDontsId.noCatheterTrain,
    polarity: LearnDosDontsPolarity.dont,
  ),
  LearnDosDontsEntry(
    id: LearnDosDontsId.noSubstituteClinician,
    polarity: LearnDosDontsPolarity.dont,
  ),
];

extension LearnDosDontsIdL10n on LearnDosDontsId {
  String text(AppLocalizations l10n) {
    switch (this) {
      case LearnDosDontsId.releaseBetweenReps:
        return l10n.learnDosDontsReleaseBetweenRepsText;
      case LearnDosDontsId.breatheNormally:
        return l10n.learnDosDontsBreatheNormallyText;
      case LearnDosDontsId.startShortSets:
        return l10n.learnDosDontsStartShortSetsText;
      case LearnDosDontsId.stopOnFlare:
        return l10n.learnDosDontsStopOnFlareText;
      case LearnDosDontsId.noPainThrough:
        return l10n.learnDosDontsNoPainThroughText;
      case LearnDosDontsId.noCompensate:
        return l10n.learnDosDontsNoCompensateText;
      case LearnDosDontsId.noCatheterTrain:
        return l10n.learnDosDontsNoCatheterTrainText;
      case LearnDosDontsId.noSubstituteClinician:
        return l10n.learnDosDontsNoSubstituteClinicianText;
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

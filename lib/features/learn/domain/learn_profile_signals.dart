import 'package:kegel_master/features/onboarding/domain/onboarding_profile.dart';

/// Pelvic-structure content grouping for Learn (labels are l10n / Task 3).
enum AnatomyTrack {
  /// Default when [GenderIdentity.male].
  maleTypical,

  /// Default when [GenderIdentity.female].
  femaleTypical,
}

/// Learn-oriented values derived from [OnboardingProfile] and snapshot catheter.
///
/// **Training pivot:** [trainingPivotActive] matches [hasHypertonicityRiskSymptom]
/// (either [Symptom.chronicPelvicPain] or [Symptom.difficultyStartingStream]).
/// Task 8 will add override semantics.
///
/// **Troubleshooter default tab** (fixed order: 0 urge → 1 stress → 2 hypertonicity):
/// When the pivot applies, tab **2** wins over urge/stress. Otherwise:
/// [Symptom.suddenUrges] → 0; [Symptom.leakingCoughSneeze] → 1; if both without
/// pivot → **0** (urge first / neutral). No mappable symptom (e.g. only [Symptom.none])
/// → **0**.
///
/// **Active catheter:** true if [OnboardingProfile.hasCatheter] **or**
/// [OnboardingSnapshot.catheterActive] is true (snapshot is authoritative for UI
/// when persisted).
class LearnProfileSignals {
  const LearnProfileSignals({
    required this.hasHypertonicityRiskSymptom,
    required this.trainingPivotActive,
    required this.hasActiveCatheter,
    required this.suggestedAnatomyTrack,
    required this.troubleshooterDefaultTabIndex,
  });

  final bool hasHypertonicityRiskSymptom;
  final bool trainingPivotActive;
  final bool hasActiveCatheter;
  final AnatomyTrack? suggestedAnatomyTrack;
  final int troubleshooterDefaultTabIndex;

  /// [catheterActiveSnapshot] is [OnboardingSnapshot.catheterActive].
  factory LearnProfileSignals.fromProfile({
    required OnboardingProfile profile,
    required bool catheterActiveSnapshot,
  }) {
    final bool hasHypertonicityRiskSymptom =
        profile.symptoms.contains(Symptom.chronicPelvicPain) ||
        profile.symptoms.contains(Symptom.difficultyStartingStream);
    final bool trainingPivotActive = hasHypertonicityRiskSymptom;
    final bool hasActiveCatheter =
        profile.hasCatheter || catheterActiveSnapshot;
    final AnatomyTrack? suggestedAnatomyTrack = switch (profile.gender) {
      GenderIdentity.male => AnatomyTrack.maleTypical,
      GenderIdentity.female => AnatomyTrack.femaleTypical,
      GenderIdentity.nonBinary => null,
    };
    final int troubleshooterDefaultTabIndex =
        troubleshooterDefaultTabIndexFor(
          trainingPivotActive: trainingPivotActive,
          symptoms: profile.symptoms,
        );
    return LearnProfileSignals(
      hasHypertonicityRiskSymptom: hasHypertonicityRiskSymptom,
      trainingPivotActive: trainingPivotActive,
      hasActiveCatheter: hasActiveCatheter,
      suggestedAnatomyTrack: suggestedAnatomyTrack,
      troubleshooterDefaultTabIndex: troubleshooterDefaultTabIndex,
    );
  }
}

/// Tab indices: 0 urge, 1 stress, 2 hypertonicity-style ([CONTEXT.md]).
int troubleshooterDefaultTabIndexFor({
  required bool trainingPivotActive,
  required Set<Symptom> symptoms,
}) {
  if (trainingPivotActive) {
    return 2;
  }
  final bool urge = symptoms.contains(Symptom.suddenUrges);
  final bool stress = symptoms.contains(Symptom.leakingCoughSneeze);
  if (urge && stress) {
    return 0;
  }
  if (urge) {
    return 0;
  }
  if (stress) {
    return 1;
  }
  return 0;
}

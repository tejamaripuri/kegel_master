import 'package:kegel_master/features/onboarding/domain/onboarding_profile.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';

SessionConfig sessionPrescriptionFromProfile(OnboardingProfile profile) {
  SessionConfig c = SessionConfig.defaults;

  switch (profile.ageBand) {
    case AgeBand.age18to34:
      break;
    case AgeBand.age35to54:
      c = c.copyWith(
        relaxSeconds: c.relaxSeconds + 2,
        bufferBetweenSetsSeconds: c.bufferBetweenSetsSeconds + 2,
      );
      break;
    case AgeBand.age55plus:
      c = c.copyWith(
        relaxSeconds: c.relaxSeconds + 4,
        bufferBetweenSetsSeconds: c.bufferBetweenSetsSeconds + 4,
        repsPerSet: 8,
        targetSets: 2,
      );
      break;
  }

  switch (profile.primaryGoal) {
    case PrimaryGoal.postpartumRecovery:
    case PrimaryGoal.postSurgicalProstateRecovery:
      c = c.copyWith(
        repsPerSet: (c.repsPerSet - 2).clamp(1, 1000),
        targetSets: (c.targetSets - 1).clamp(1, 1000),
        bufferBetweenSetsSeconds: c.bufferBetweenSetsSeconds + 5,
      );
      break;
    case PrimaryGoal.preventionMaintenance:
      break;
    case PrimaryGoal.sexualPerformanceEnhancement:
      c = c.copyWith(
        squeezeSeconds: c.squeezeSeconds + 1,
        relaxSeconds: (c.relaxSeconds - 1).clamp(0, 1000),
      );
      break;
    case PrimaryGoal.incontinenceManagement:
      c = c.copyWith(
        repsPerSet: c.repsPerSet + 2,
        bufferBetweenSetsSeconds: c.bufferBetweenSetsSeconds + 2,
      );
      break;
  }

  final bool gentleClinical = profile.clinicalHistory.contains(
        ClinicalHistory.birthWithin8Weeks,
      ) ||
      profile.clinicalHistory.contains(ClinicalHistory.recentProstateSurgery);
  if (gentleClinical) {
    c = c.copyWith(
      bufferBetweenSetsSeconds: c.bufferBetweenSetsSeconds + 2,
    );
  }

  return SessionConfig(
    squeezeSeconds: c.squeezeSeconds,
    relaxSeconds: c.relaxSeconds,
    bufferBetweenSetsSeconds: c.bufferBetweenSetsSeconds,
    repsPerSet: c.repsPerSet,
    targetSets: c.targetSets,
  );
}

import 'package:kegel_master/features/onboarding/domain/onboarding_profile.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';

enum KegelClinicalPreset {
  foundationalBeginner,
  advancedEndurance,
  postpartumRestorative,
  postProstatectomyRecovery,
  geriatricSarcopenia,
  sexualPerformance,
}

extension KegelClinicalPresetConfig on KegelClinicalPreset {
  SessionConfig get config => switch (this) {
        KegelClinicalPreset.foundationalBeginner => SessionConfig(
            squeezeSeconds: 3,
            relaxSeconds: 3,
            bufferBetweenSetsSeconds: 60,
            repsPerSet: 10,
            targetSets: 3,
          ),
        KegelClinicalPreset.advancedEndurance => SessionConfig(
            squeezeSeconds: 10,
            relaxSeconds: 10,
            bufferBetweenSetsSeconds: 60,
            repsPerSet: 10,
            targetSets: 3,
          ),
        KegelClinicalPreset.postpartumRestorative => SessionConfig(
            squeezeSeconds: 5,
            relaxSeconds: 10,
            bufferBetweenSetsSeconds: 90,
            repsPerSet: 10,
            targetSets: 3,
          ),
        KegelClinicalPreset.postProstatectomyRecovery => SessionConfig(
            squeezeSeconds: 10,
            relaxSeconds: 10,
            bufferBetweenSetsSeconds: 60,
            repsPerSet: 10,
            targetSets: 4,
          ),
        KegelClinicalPreset.geriatricSarcopenia => SessionConfig(
            squeezeSeconds: 3,
            relaxSeconds: 5,
            bufferBetweenSetsSeconds: 120,
            repsPerSet: 10,
            targetSets: 3,
          ),
        KegelClinicalPreset.sexualPerformance => SessionConfig(
            squeezeSeconds: 10,
            relaxSeconds: 10,
            bufferBetweenSetsSeconds: 45,
            repsPerSet: 15,
            targetSets: 3,
          ),
      };
}

KegelClinicalPreset presetForProfile(OnboardingProfile p) {
  switch (p.primaryGoal) {
    case PrimaryGoal.postSurgicalProstateRecovery:
      return KegelClinicalPreset.postProstatectomyRecovery;
    case PrimaryGoal.postpartumRecovery:
      return KegelClinicalPreset.postpartumRestorative;
    case PrimaryGoal.sexualPerformanceEnhancement:
      return KegelClinicalPreset.sexualPerformance;
    case PrimaryGoal.preventionMaintenance:
      if (p.ageBand == AgeBand.age55plus) {
        return KegelClinicalPreset.geriatricSarcopenia;
      }
      return KegelClinicalPreset.advancedEndurance;
    case PrimaryGoal.incontinenceManagement:
      if (p.ageBand == AgeBand.age55plus) {
        return KegelClinicalPreset.geriatricSarcopenia;
      }
      return KegelClinicalPreset.foundationalBeginner;
  }
}

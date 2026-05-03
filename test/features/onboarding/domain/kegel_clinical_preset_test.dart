import 'package:flutter_test/flutter_test.dart';
import 'package:kegel_master/features/onboarding/domain/kegel_clinical_preset.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_profile.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';

OnboardingProfile _p({
  required PrimaryGoal goal,
  AgeBand age = AgeBand.age18to34,
  Set<Symptom> symptoms = const {Symptom.none},
  Set<ClinicalHistory> clinical = const {ClinicalHistory.none},
  GenderIdentity gender = GenderIdentity.female,
}) {
  return OnboardingProfile(
    gender: gender,
    primaryGoal: goal,
    ageBand: age,
    symptoms: symptoms,
    clinicalHistory: clinical,
  );
}

void _expectConfig(SessionConfig c, SessionConfig expected) {
  expect(c.squeezeSeconds, expected.squeezeSeconds);
  expect(c.relaxSeconds, expected.relaxSeconds);
  expect(c.bufferBetweenSetsSeconds, expected.bufferBetweenSetsSeconds);
  expect(c.repsPerSet, expected.repsPerSet);
  expect(c.targetSets, expected.targetSets);
}

void main() {
  final SessionConfig foundational = SessionConfig(
    squeezeSeconds: 3,
    relaxSeconds: 3,
    bufferBetweenSetsSeconds: 60,
    repsPerSet: 10,
    targetSets: 3,
  );
  final SessionConfig advanced = SessionConfig(
    squeezeSeconds: 10,
    relaxSeconds: 10,
    bufferBetweenSetsSeconds: 60,
    repsPerSet: 10,
    targetSets: 3,
  );
  final SessionConfig postpartum = SessionConfig(
    squeezeSeconds: 5,
    relaxSeconds: 10,
    bufferBetweenSetsSeconds: 90,
    repsPerSet: 10,
    targetSets: 3,
  );
  final SessionConfig prostate = SessionConfig(
    squeezeSeconds: 10,
    relaxSeconds: 10,
    bufferBetweenSetsSeconds: 60,
    repsPerSet: 10,
    targetSets: 4,
  );
  final SessionConfig geriatric = SessionConfig(
    squeezeSeconds: 3,
    relaxSeconds: 5,
    bufferBetweenSetsSeconds: 120,
    repsPerSet: 10,
    targetSets: 3,
  );
  final SessionConfig sexual = SessionConfig(
    squeezeSeconds: 10,
    relaxSeconds: 10,
    bufferBetweenSetsSeconds: 45,
    repsPerSet: 15,
    targetSets: 3,
  );

  test('preset config getters match clinical table', () {
    _expectConfig(
      KegelClinicalPreset.foundationalBeginner.config,
      foundational,
    );
    _expectConfig(KegelClinicalPreset.advancedEndurance.config, advanced);
    _expectConfig(
      KegelClinicalPreset.postpartumRestorative.config,
      postpartum,
    );
    _expectConfig(
      KegelClinicalPreset.postProstatectomyRecovery.config,
      prostate,
    );
    _expectConfig(KegelClinicalPreset.geriatricSarcopenia.config, geriatric);
    _expectConfig(KegelClinicalPreset.sexualPerformance.config, sexual);
  });

  test('post-surgical prostate goal → postProstatectomyRecovery', () {
    expect(
      presetForProfile(
        _p(goal: PrimaryGoal.postSurgicalProstateRecovery),
      ),
      KegelClinicalPreset.postProstatectomyRecovery,
    );
  });

  test('postpartum recovery → postpartumRestorative', () {
    expect(
      presetForProfile(_p(goal: PrimaryGoal.postpartumRecovery)),
      KegelClinicalPreset.postpartumRestorative,
    );
  });

  test('postpartum + 55+ still postpartum (priority over geriatric)', () {
    expect(
      presetForProfile(
        _p(goal: PrimaryGoal.postpartumRecovery, age: AgeBand.age55plus),
      ),
      KegelClinicalPreset.postpartumRestorative,
    );
  });

  test('sexual performance → sexualPerformance including 55+', () {
    expect(
      presetForProfile(
        _p(goal: PrimaryGoal.sexualPerformanceEnhancement),
      ),
      KegelClinicalPreset.sexualPerformance,
    );
    expect(
      presetForProfile(
        _p(
          goal: PrimaryGoal.sexualPerformanceEnhancement,
          age: AgeBand.age55plus,
        ),
      ),
      KegelClinicalPreset.sexualPerformance,
    );
  });

  test('55+ prevention → geriatric', () {
    expect(
      presetForProfile(
        _p(
          goal: PrimaryGoal.preventionMaintenance,
          age: AgeBand.age55plus,
        ),
      ),
      KegelClinicalPreset.geriatricSarcopenia,
    );
  });

  test('55+ incontinence → geriatric', () {
    expect(
      presetForProfile(
        _p(
          goal: PrimaryGoal.incontinenceManagement,
          age: AgeBand.age55plus,
        ),
      ),
      KegelClinicalPreset.geriatricSarcopenia,
    );
  });

  test('18-34 prevention → advanced', () {
    expect(
      presetForProfile(
        _p(goal: PrimaryGoal.preventionMaintenance, age: AgeBand.age18to34),
      ),
      KegelClinicalPreset.advancedEndurance,
    );
  });

  test('35-54 prevention → advanced', () {
    expect(
      presetForProfile(
        _p(goal: PrimaryGoal.preventionMaintenance, age: AgeBand.age35to54),
      ),
      KegelClinicalPreset.advancedEndurance,
    );
  });

  test('18-34 incontinence → foundational', () {
    expect(
      presetForProfile(
        _p(goal: PrimaryGoal.incontinenceManagement, age: AgeBand.age18to34),
      ),
      KegelClinicalPreset.foundationalBeginner,
    );
  });

  test('symptoms do not change preset', () {
    final OnboardingProfile a = _p(
      goal: PrimaryGoal.preventionMaintenance,
      symptoms: {Symptom.none},
    );
    final OnboardingProfile b = _p(
      goal: PrimaryGoal.preventionMaintenance,
      symptoms: {Symptom.chronicPelvicPain, Symptom.suddenUrges},
    );
    expect(presetForProfile(a), presetForProfile(b));
  });
}

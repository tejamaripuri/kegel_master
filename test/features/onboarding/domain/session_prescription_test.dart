import 'package:flutter_test/flutter_test.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_profile.dart';
import 'package:kegel_master/features/onboarding/domain/session_prescription.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';

OnboardingProfile _base({
  required Set<Symptom> symptoms,
  Set<ClinicalHistory> clinical = const {ClinicalHistory.none},
}) {
  return OnboardingProfile(
    gender: GenderIdentity.male,
    primaryGoal: PrimaryGoal.preventionMaintenance,
    ageBand: AgeBand.age18to34,
    symptoms: symptoms,
    clinicalHistory: clinical,
  );
}

void main() {
  test('symptoms do not change prescription', () {
    final OnboardingProfile a = _base(symptoms: {Symptom.none});
    final OnboardingProfile b = _base(
      symptoms: {Symptom.chronicPelvicPain, Symptom.suddenUrges},
    );
    expect(
      sessionPrescriptionFromProfile(a).relaxSeconds,
      sessionPrescriptionFromProfile(b).relaxSeconds,
    );
    expect(
      sessionPrescriptionFromProfile(a).repsPerSet,
      sessionPrescriptionFromProfile(b).repsPerSet,
    );
  });

  test('age 55+ increases relax and buffer and lowers volume', () {
    final OnboardingProfile p = OnboardingProfile(
      gender: GenderIdentity.nonBinary,
      primaryGoal: PrimaryGoal.preventionMaintenance,
      ageBand: AgeBand.age55plus,
      symptoms: {Symptom.none},
      clinicalHistory: {ClinicalHistory.none},
    );
    final SessionConfig c = sessionPrescriptionFromProfile(p);
    expect(c.relaxSeconds, greaterThan(SessionConfig.defaults.relaxSeconds));
    expect(
      c.bufferBetweenSetsSeconds,
      greaterThan(SessionConfig.defaults.bufferBetweenSetsSeconds),
    );
    expect(c.repsPerSet, lessThan(SessionConfig.defaults.repsPerSet));
  });

  test('postpartum goal gentler than defaults at same age', () {
    final SessionConfig prevention = sessionPrescriptionFromProfile(
      OnboardingProfile(
        gender: GenderIdentity.female,
        primaryGoal: PrimaryGoal.preventionMaintenance,
        ageBand: AgeBand.age18to34,
        symptoms: {Symptom.none},
        clinicalHistory: {ClinicalHistory.none},
      ),
    );
    final SessionConfig postpartum = sessionPrescriptionFromProfile(
      OnboardingProfile(
        gender: GenderIdentity.female,
        primaryGoal: PrimaryGoal.postpartumRecovery,
        ageBand: AgeBand.age18to34,
        symptoms: {Symptom.none},
        clinicalHistory: {ClinicalHistory.none},
      ),
    );
    expect(postpartum.repsPerSet, lessThanOrEqualTo(prevention.repsPerSet));
  });
}

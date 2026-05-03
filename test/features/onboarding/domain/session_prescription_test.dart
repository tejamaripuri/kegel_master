import 'package:flutter_test/flutter_test.dart';
import 'package:kegel_master/features/onboarding/domain/kegel_clinical_preset.dart';
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
  test('sessionPrescriptionFromProfile matches presetForProfile.config', () {
    final OnboardingProfile p = OnboardingProfile(
      gender: GenderIdentity.male,
      primaryGoal: PrimaryGoal.incontinenceManagement,
      ageBand: AgeBand.age35to54,
      symptoms: {Symptom.none},
      clinicalHistory: {ClinicalHistory.none},
    );
    expect(
      sessionPrescriptionFromProfile(p),
      presetForProfile(p).config,
    );
  });

  test('symptoms do not change prescription', () {
    final OnboardingProfile a = _base(symptoms: {Symptom.none});
    final OnboardingProfile b = _base(
      symptoms: {Symptom.chronicPelvicPain, Symptom.suddenUrges},
    );
    expect(
      sessionPrescriptionFromProfile(a),
      sessionPrescriptionFromProfile(b),
    );
  });

  test('prevention 18-34 matches advanced endurance config', () {
    final SessionConfig c = sessionPrescriptionFromProfile(
      OnboardingProfile(
        gender: GenderIdentity.nonBinary,
        primaryGoal: PrimaryGoal.preventionMaintenance,
        ageBand: AgeBand.age18to34,
        symptoms: {Symptom.none},
        clinicalHistory: {ClinicalHistory.none},
      ),
    );
    expect(c, KegelClinicalPreset.advancedEndurance.config);
  });
}

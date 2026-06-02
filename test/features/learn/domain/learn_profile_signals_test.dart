import 'package:flutter_test/flutter_test.dart';
import 'package:kegel_master/features/learn/domain/learn_profile_signals.dart';
import 'package:kegel_master/features/onboarding/application/onboarding_gate.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_profile.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_snapshot.dart';

import '../../../fakes/fake_onboarding_persistence.dart';

OnboardingProfile _profile({
  GenderIdentity gender = GenderIdentity.male,
  Set<Symptom> symptoms = const <Symptom>{Symptom.none},
  Set<ClinicalHistory> clinicalHistory = const <ClinicalHistory>{
    ClinicalHistory.none,
  },
}) {
  return OnboardingProfile(
    gender: gender,
    primaryGoal: PrimaryGoal.preventionMaintenance,
    ageBand: AgeBand.age18to34,
    symptoms: symptoms,
    clinicalHistory: clinicalHistory,
  );
}

void main() {
  group('LearnProfileSignals.fromProfile', () {
    test('urge-only maps to troubleshooter tab 0', () {
      final LearnProfileSignals s = LearnProfileSignals.fromProfile(
        profile: _profile(symptoms: const <Symptom>{Symptom.suddenUrges}),
        catheterActiveSnapshot: false,
      );
      expect(s.trainingPivotActive, isFalse);
      expect(s.troubleshooterDefaultTabIndex, 0);
    });

    test('stress-only maps to troubleshooter tab 1', () {
      final LearnProfileSignals s = LearnProfileSignals.fromProfile(
        profile: _profile(
          symptoms: const <Symptom>{Symptom.leakingCoughSneeze},
        ),
        catheterActiveSnapshot: false,
      );
      expect(s.troubleshooterDefaultTabIndex, 1);
    });

    test('pivot-only (chronic pelvic pain) maps to tab 2 and pivot active', () {
      final LearnProfileSignals s = LearnProfileSignals.fromProfile(
        profile: _profile(
          symptoms: const <Symptom>{Symptom.chronicPelvicPain},
        ),
        catheterActiveSnapshot: false,
      );
      expect(s.hasHypertonicityRiskSymptom, isTrue);
      expect(s.trainingPivotActive, isTrue);
      expect(s.troubleshooterDefaultTabIndex, 2);
    });

    test('difficulty starting stream triggers pivot', () {
      final LearnProfileSignals s = LearnProfileSignals.fromProfile(
        profile: _profile(
          symptoms: const <Symptom>{Symptom.difficultyStartingStream},
        ),
        catheterActiveSnapshot: false,
      );
      expect(s.trainingPivotActive, isTrue);
      expect(s.troubleshooterDefaultTabIndex, 2);
    });

    test('urge and pivot: pivot wins tab 2', () {
      final LearnProfileSignals s = LearnProfileSignals.fromProfile(
        profile: _profile(
          symptoms: const <Symptom>{
            Symptom.suddenUrges,
            Symptom.chronicPelvicPain,
          },
        ),
        catheterActiveSnapshot: false,
      );
      expect(s.trainingPivotActive, isTrue);
      expect(s.troubleshooterDefaultTabIndex, 2);
    });

    test('urge and stress without pivot: urge tab 0', () {
      final LearnProfileSignals s = LearnProfileSignals.fromProfile(
        profile: _profile(
          symptoms: const <Symptom>{
            Symptom.suddenUrges,
            Symptom.leakingCoughSneeze,
          },
        ),
        catheterActiveSnapshot: false,
      );
      expect(s.trainingPivotActive, isFalse);
      expect(s.troubleshooterDefaultTabIndex, 0);
    });

    test('symptom none only defaults tab 0', () {
      final LearnProfileSignals s = LearnProfileSignals.fromProfile(
        profile: _profile(symptoms: const <Symptom>{Symptom.none}),
        catheterActiveSnapshot: false,
      );
      expect(s.troubleshooterDefaultTabIndex, 0);
    });

    test('non-binary has null suggested anatomy track', () {
      final LearnProfileSignals s = LearnProfileSignals.fromProfile(
        profile: _profile(gender: GenderIdentity.nonBinary),
        catheterActiveSnapshot: false,
      );
      expect(s.suggestedAnatomyTrack, isNull);
    });

    test('male and female suggest distinct anatomy tracks', () {
      final LearnProfileSignals male = LearnProfileSignals.fromProfile(
        profile: _profile(gender: GenderIdentity.male),
        catheterActiveSnapshot: false,
      );
      final LearnProfileSignals female = LearnProfileSignals.fromProfile(
        profile: _profile(gender: GenderIdentity.female),
        catheterActiveSnapshot: false,
      );
      expect(male.suggestedAnatomyTrack, AnatomyTrack.maleTypical);
      expect(female.suggestedAnatomyTrack, AnatomyTrack.femaleTypical);
    });

    test('hasActiveCatheter is true if profile has catheter', () {
      final LearnProfileSignals s = LearnProfileSignals.fromProfile(
        profile: _profile(
          clinicalHistory: const <ClinicalHistory>{ClinicalHistory.catheter},
        ),
        catheterActiveSnapshot: false,
      );
      expect(s.hasActiveCatheter, isTrue);
    });

    test('hasActiveCatheter is true if snapshot catheter only', () {
      final LearnProfileSignals s = LearnProfileSignals.fromProfile(
        profile: _profile(),
        catheterActiveSnapshot: true,
      );
      expect(s.hasActiveCatheter, isTrue);
    });

    test('hasActiveCatheter is false when neither', () {
      final LearnProfileSignals s = LearnProfileSignals.fromProfile(
        profile: _profile(),
        catheterActiveSnapshot: false,
      );
      expect(s.hasActiveCatheter, isFalse);
    });
  });

  group('OnboardingGate.learnProfileSignalsOrNull', () {
    test('returns null when profile is null', () async {
      final FakeOnboardingPersistence persistence = FakeOnboardingPersistence(
        initial: const OnboardingSnapshot(
          onboardingComplete: true,
          catheterActive: false,
          profile: null,
        ),
      );
      final OnboardingGate gate = OnboardingGate(persistence);
      await gate.load();
      expect(gate.learnProfileSignalsOrNull(), isNull);
    });

    test('returns signals when profile is set', () async {
      final OnboardingProfile p = _profile(
        symptoms: const <Symptom>{Symptom.suddenUrges},
      );
      final FakeOnboardingPersistence persistence = FakeOnboardingPersistence(
        initial: OnboardingSnapshot(
          onboardingComplete: true,
          catheterActive: false,
          profile: p,
        ),
      );
      final OnboardingGate gate = OnboardingGate(persistence);
      await gate.load();
      final LearnProfileSignals? s = gate.learnProfileSignalsOrNull();
      expect(s, isNotNull);
      expect(s!.troubleshooterDefaultTabIndex, 0);
    });
  });
}

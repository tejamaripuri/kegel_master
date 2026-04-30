import 'package:flutter_test/flutter_test.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_mutual_exclusion.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_profile.dart';

void main() {
  group('symptoms', () {
    test('selecting none clears other symptoms', () {
      final Set<Symptom> start = {
        Symptom.leakingCoughSneeze,
        Symptom.suddenUrges,
      };
      final Set<Symptom> out =
          OnboardingMutualExclusion.toggleSymptom(start, Symptom.none);
      expect(out, equals(<Symptom>{Symptom.none}));
    });

    test('selecting non-none clears none', () {
      final Set<Symptom> start = {Symptom.none};
      final Set<Symptom> out = OnboardingMutualExclusion.toggleSymptom(
        start,
        Symptom.chronicPelvicPain,
      );
      expect(out, equals(<Symptom>{Symptom.chronicPelvicPain}));
    });
  });

  group('clinicalHistory', () {
    test('selecting none clears other flags', () {
      final Set<ClinicalHistory> start = {
        ClinicalHistory.birthWithin8Weeks,
      };
      final Set<ClinicalHistory> out =
          OnboardingMutualExclusion.toggleClinicalHistory(
        start,
        ClinicalHistory.none,
      );
      expect(out, equals(<ClinicalHistory>{ClinicalHistory.none}));
    });

    test('selecting catheter clears none', () {
      final Set<ClinicalHistory> start = {ClinicalHistory.none};
      final Set<ClinicalHistory> out =
          OnboardingMutualExclusion.toggleClinicalHistory(
        start,
        ClinicalHistory.catheter,
      );
      expect(out, equals(<ClinicalHistory>{ClinicalHistory.catheter}));
    });
  });
}

import 'package:kegel_master/features/onboarding/domain/onboarding_profile.dart';

class OnboardingMutualExclusion {
  const OnboardingMutualExclusion._();

  static Set<Symptom> toggleSymptom(Set<Symptom> current, Symptom tapped) {
    if (tapped == Symptom.none) {
      return <Symptom>{Symptom.none};
    }
    final Set<Symptom> next = Set<Symptom>.from(current)..remove(Symptom.none);
    if (next.contains(tapped)) {
      next.remove(tapped);
    } else {
      next.add(tapped);
    }
    if (next.isEmpty) {
      return <Symptom>{Symptom.none};
    }
    return next;
  }

  static Set<ClinicalHistory> toggleClinicalHistory(
    Set<ClinicalHistory> current,
    ClinicalHistory tapped,
  ) {
    if (tapped == ClinicalHistory.none) {
      return <ClinicalHistory>{ClinicalHistory.none};
    }
    final Set<ClinicalHistory> next = Set<ClinicalHistory>.from(current)
      ..remove(ClinicalHistory.none);
    if (next.contains(tapped)) {
      next.remove(tapped);
    } else {
      next.add(tapped);
    }
    if (next.isEmpty) {
      return <ClinicalHistory>{ClinicalHistory.none};
    }
    return next;
  }
}

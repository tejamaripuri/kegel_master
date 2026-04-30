enum GenderIdentity { male, female, nonBinary }

enum PrimaryGoal {
  postpartumRecovery,
  postSurgicalProstateRecovery,
  preventionMaintenance,
  sexualPerformanceEnhancement,
  incontinenceManagement,
}

enum AgeBand { age18to34, age35to54, age55plus }

enum Symptom {
  leakingCoughSneeze,
  suddenUrges,
  difficultyStartingStream,
  chronicPelvicPain,
  none,
}

enum ClinicalHistory {
  birthWithin8Weeks,
  recentProstateSurgery,
  catheter,
  none,
}

class OnboardingProfile {
  const OnboardingProfile({
    required this.gender,
    required this.primaryGoal,
    required this.ageBand,
    required this.symptoms,
    required this.clinicalHistory,
  });

  final GenderIdentity gender;
  final PrimaryGoal primaryGoal;
  final AgeBand ageBand;
  final Set<Symptom> symptoms;
  final Set<ClinicalHistory> clinicalHistory;

  bool get hasCatheter => clinicalHistory.contains(ClinicalHistory.catheter);

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'gender': gender.name,
      'primaryGoal': primaryGoal.name,
      'ageBand': ageBand.name,
      'symptoms': symptoms.map((e) => e.name).toList(),
      'clinicalHistory': clinicalHistory.map((e) => e.name).toList(),
    };
  }

  static OnboardingProfile fromJson(Map<String, Object?> json) {
    return OnboardingProfile(
      gender: GenderIdentity.values.byName(json['gender']! as String),
      primaryGoal: PrimaryGoal.values.byName(json['primaryGoal']! as String),
      ageBand: AgeBand.values.byName(json['ageBand']! as String),
      symptoms: (json['symptoms']! as List<dynamic>)
          .map((e) => Symptom.values.byName(e as String))
          .toSet(),
      clinicalHistory: (json['clinicalHistory']! as List<dynamic>)
          .map((e) => ClinicalHistory.values.byName(e as String))
          .toSet(),
    );
  }
}

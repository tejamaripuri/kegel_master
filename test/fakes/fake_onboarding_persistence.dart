import 'package:kegel_master/features/onboarding/data/onboarding_persistence.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_profile.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_snapshot.dart';

class FakeOnboardingPersistence implements OnboardingPersistence {
  FakeOnboardingPersistence({OnboardingSnapshot? initial})
      : snapshot = initial ?? FakeOnboardingPersistence.completedSnapshot;

  static final OnboardingSnapshot completedSnapshot = OnboardingSnapshot(
    onboardingComplete: true,
    catheterActive: false,
    profile: OnboardingProfile(
      gender: GenderIdentity.male,
      primaryGoal: PrimaryGoal.preventionMaintenance,
      ageBand: AgeBand.age18to34,
      symptoms: {Symptom.none},
      clinicalHistory: {ClinicalHistory.none},
    ),
  );

  OnboardingSnapshot snapshot;

  @override
  Future<void> clear() async {
    snapshot = OnboardingSnapshot.empty;
  }

  @override
  Future<OnboardingSnapshot> readSnapshot() async => snapshot;

  @override
  Future<void> writeSnapshot(OnboardingSnapshot value) async {
    snapshot = value;
  }
}

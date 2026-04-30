import 'package:kegel_master/features/onboarding/domain/onboarding_profile.dart';

class OnboardingSnapshot {
  const OnboardingSnapshot({
    required this.onboardingComplete,
    required this.catheterActive,
    this.disclaimerAcceptedAt,
    this.profile,
  });

  final bool onboardingComplete;
  final bool catheterActive;
  final DateTime? disclaimerAcceptedAt;
  final OnboardingProfile? profile;

  static const OnboardingSnapshot empty = OnboardingSnapshot(
    onboardingComplete: false,
    catheterActive: false,
  );
}

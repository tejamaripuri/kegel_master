import 'package:flutter_test/flutter_test.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_profile.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_redirect.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_snapshot.dart';

OnboardingProfile _minimalProfile({required bool catheter}) {
  return OnboardingProfile(
    gender: GenderIdentity.female,
    primaryGoal: PrimaryGoal.preventionMaintenance,
    ageBand: AgeBand.age18to34,
    symptoms: {Symptom.chronicPelvicPain},
    clinicalHistory: catheter
        ? {ClinicalHistory.catheter}
        : {ClinicalHistory.none},
  );
}

void main() {
  test('incomplete onboarding sends /home to /onboarding', () {
    expect(
      resolveOnboardingRedirect(
        path: '/home',
        snapshot: OnboardingSnapshot.empty,
      ),
      '/onboarding',
    );
  });

  test('incomplete allows /onboarding', () {
    expect(
      resolveOnboardingRedirect(
        path: '/onboarding',
        snapshot: OnboardingSnapshot.empty,
      ),
      isNull,
    );
  });

  test('complete + catheter blocks /session to /learn', () {
    final OnboardingSnapshot s = OnboardingSnapshot(
      onboardingComplete: true,
      catheterActive: true,
      profile: _minimalProfile(catheter: true),
    );
    expect(resolveOnboardingRedirect(path: '/session', snapshot: s), '/learn');
  });

  test('complete + catheter allows /settings', () {
    final OnboardingSnapshot s = OnboardingSnapshot(
      onboardingComplete: true,
      catheterActive: true,
      profile: _minimalProfile(catheter: true),
    );
    expect(resolveOnboardingRedirect(path: '/settings', snapshot: s), isNull);
  });

  test('complete + catheter redirects /home to /learn', () {
    final OnboardingSnapshot s = OnboardingSnapshot(
      onboardingComplete: true,
      catheterActive: true,
      profile: _minimalProfile(catheter: true),
    );
    expect(resolveOnboardingRedirect(path: '/home', snapshot: s), '/learn');
  });

  test('complete + catheter with pain in profile still catheter rules', () {
    final OnboardingSnapshot s = OnboardingSnapshot(
      onboardingComplete: true,
      catheterActive: true,
      profile: _minimalProfile(catheter: true),
    );
    expect(resolveOnboardingRedirect(path: '/session', snapshot: s), '/learn');
  });

  test('complete without catheter allows /home', () {
    final OnboardingSnapshot s = OnboardingSnapshot(
      onboardingComplete: true,
      catheterActive: false,
      profile: _minimalProfile(catheter: false),
    );
    expect(resolveOnboardingRedirect(path: '/home', snapshot: s), isNull);
  });

  test('complete catheter maps slash to learn', () {
    final OnboardingSnapshot s = OnboardingSnapshot(
      onboardingComplete: true,
      catheterActive: true,
      profile: OnboardingProfile(
        gender: GenderIdentity.male,
        primaryGoal: PrimaryGoal.preventionMaintenance,
        ageBand: AgeBand.age18to34,
        symptoms: {Symptom.none},
        clinicalHistory: {ClinicalHistory.catheter},
      ),
    );
    expect(resolveOnboardingRedirect(path: '/', snapshot: s), '/learn');
  });
}

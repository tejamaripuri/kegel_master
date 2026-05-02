import 'package:flutter_test/flutter_test.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_profile.dart';
import 'package:kegel_master/features/onboarding/domain/session_prescription.dart';
import 'package:kegel_master/features/progress/domain/effective_session_config.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';

void _expectSameConfig(SessionConfig actual, SessionConfig expected) {
  expect(actual.squeezeSeconds, expected.squeezeSeconds);
  expect(actual.relaxSeconds, expected.relaxSeconds);
  expect(
    actual.bufferBetweenSetsSeconds,
    expected.bufferBetweenSetsSeconds,
  );
  expect(actual.repsPerSet, expected.repsPerSet);
  expect(actual.targetSets, expected.targetSets);
}

void main() {
  final OnboardingProfile minimalProfile = OnboardingProfile(
    gender: GenderIdentity.male,
    primaryGoal: PrimaryGoal.preventionMaintenance,
    ageBand: AgeBand.age18to34,
    symptoms: {Symptom.none},
    clinicalHistory: {ClinicalHistory.none},
  );

  test('non-null mirror wins when onboarding complete and profile present', () {
    final SessionConfig mirror = SessionConfig(
      squeezeSeconds: 7,
      relaxSeconds: 8,
      bufferBetweenSetsSeconds: 9,
      repsPerSet: 11,
      targetSets: 4,
    );
    final SessionConfig result = resolveEffectiveSessionConfig(
      mirror: mirror,
      onboardingComplete: true,
      profile: minimalProfile,
    );
    _expectSameConfig(result, mirror);
  });

  test(
    'null mirror + onboarding complete + profile uses sessionPrescriptionFromProfile',
    () {
      final SessionConfig result = resolveEffectiveSessionConfig(
        mirror: null,
        onboardingComplete: true,
        profile: minimalProfile,
      );
      _expectSameConfig(
        result,
        sessionPrescriptionFromProfile(minimalProfile),
      );
    },
  );

  test('null mirror + onboarding incomplete returns defaults', () {
    final SessionConfig result = resolveEffectiveSessionConfig(
      mirror: null,
      onboardingComplete: false,
      profile: minimalProfile,
    );
    _expectSameConfig(result, SessionConfig.defaults);
  });

  test('null mirror + onboarding complete + null profile returns defaults', () {
    final SessionConfig result = resolveEffectiveSessionConfig(
      mirror: null,
      onboardingComplete: true,
      profile: null,
    );
    _expectSameConfig(result, SessionConfig.defaults);
  });
}

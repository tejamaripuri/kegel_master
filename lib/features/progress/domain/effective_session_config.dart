import 'package:kegel_master/features/onboarding/domain/onboarding_profile.dart';
import 'package:kegel_master/features/onboarding/domain/session_prescription.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';

SessionConfig resolveEffectiveSessionConfig({
  required SessionConfig? mirror,
  required bool onboardingComplete,
  required OnboardingProfile? profile,
}) {
  if (mirror != null) return mirror;
  if (onboardingComplete && profile != null) {
    return sessionPrescriptionFromProfile(profile);
  }
  return SessionConfig.defaults;
}

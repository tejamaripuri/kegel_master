import 'package:kegel_master/features/onboarding/domain/kegel_clinical_preset.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_profile.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';

SessionConfig sessionPrescriptionFromProfile(OnboardingProfile profile) {
  return presetForProfile(profile).config;
}

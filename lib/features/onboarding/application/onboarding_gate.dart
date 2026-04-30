import 'package:flutter/foundation.dart';
import 'package:kegel_master/features/onboarding/data/onboarding_persistence.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_profile.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_snapshot.dart';
import 'package:kegel_master/features/onboarding/domain/session_prescription.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';

class OnboardingGate extends ChangeNotifier {
  OnboardingGate(this._persistence);

  final OnboardingPersistence _persistence;

  OnboardingSnapshot _snapshot = OnboardingSnapshot.empty;

  OnboardingSnapshot get snapshot => _snapshot;

  Future<void> load() async {
    _snapshot = await _persistence.readSnapshot();
    notifyListeners();
  }

  Future<void> setDisclaimerAccepted(DateTime when) async {
    _snapshot = OnboardingSnapshot(
      onboardingComplete: _snapshot.onboardingComplete,
      catheterActive: _snapshot.catheterActive,
      disclaimerAcceptedAt: when,
      profile: _snapshot.profile,
    );
    await _persistence.writeSnapshot(_snapshot);
    notifyListeners();
  }

  Future<void> completeWithProfile(OnboardingProfile profile) async {
    final bool catheter = profile.hasCatheter;
    _snapshot = OnboardingSnapshot(
      onboardingComplete: true,
      catheterActive: catheter,
      disclaimerAcceptedAt: _snapshot.disclaimerAcceptedAt,
      profile: profile,
    );
    await _persistence.writeSnapshot(_snapshot);
    notifyListeners();
  }

  Future<void> resetAll() async {
    await _persistence.clear();
    _snapshot = OnboardingSnapshot.empty;
    notifyListeners();
  }

  SessionConfig? currentSessionConfigOrNull() {
    final OnboardingProfile? p = _snapshot.profile;
    if (!_snapshot.onboardingComplete || p == null) {
      return null;
    }
    return sessionPrescriptionFromProfile(p);
  }
}

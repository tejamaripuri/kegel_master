import 'dart:convert';

import 'package:kegel_master/features/onboarding/domain/onboarding_profile.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_snapshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class OnboardingPersistence {
  Future<OnboardingSnapshot> readSnapshot();
  Future<void> writeSnapshot(OnboardingSnapshot snapshot);
  Future<void> clear();
}

class SharedPreferencesOnboardingPersistence implements OnboardingPersistence {
  SharedPreferencesOnboardingPersistence(this._prefs);

  final SharedPreferences _prefs;

  static const String _keySchema = 'onboarding_schema_version';
  static const String _keyComplete = 'onboarding_complete';
  static const String _keyCatheter = 'onboarding_catheter_active';
  static const String _keyDisclaimer = 'onboarding_disclaimer_accepted_at';
  static const String _keyProfileJson = 'onboarding_profile_json';

  static const int _schemaVersion = 1;

  @override
  Future<OnboardingSnapshot> readSnapshot() async {
    final bool complete = _prefs.getBool(_keyComplete) ?? false;
    final bool catheter = _prefs.getBool(_keyCatheter) ?? false;
    final String? disclaimerIso = _prefs.getString(_keyDisclaimer);
    final String? profileJson = _prefs.getString(_keyProfileJson);
    OnboardingProfile? profile;
    if (profileJson != null && profileJson.isNotEmpty) {
      profile = OnboardingProfile.fromJson(
        jsonDecode(profileJson) as Map<String, Object?>,
      );
    }
    return OnboardingSnapshot(
      onboardingComplete: complete,
      catheterActive: catheter,
      disclaimerAcceptedAt: disclaimerIso == null
          ? null
          : DateTime.tryParse(disclaimerIso),
      profile: profile,
    );
  }

  @override
  Future<void> writeSnapshot(OnboardingSnapshot snapshot) async {
    await _prefs.setInt(_keySchema, _schemaVersion);
    await _prefs.setBool(_keyComplete, snapshot.onboardingComplete);
    await _prefs.setBool(_keyCatheter, snapshot.catheterActive);
    if (snapshot.disclaimerAcceptedAt == null) {
      await _prefs.remove(_keyDisclaimer);
    } else {
      await _prefs.setString(
        _keyDisclaimer,
        snapshot.disclaimerAcceptedAt!.toIso8601String(),
      );
    }
    if (snapshot.profile == null) {
      await _prefs.remove(_keyProfileJson);
    } else {
      await _prefs.setString(
        _keyProfileJson,
        jsonEncode(snapshot.profile!.toJson()),
      );
    }
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_keySchema);
    await _prefs.remove(_keyComplete);
    await _prefs.remove(_keyCatheter);
    await _prefs.remove(_keyDisclaimer);
    await _prefs.remove(_keyProfileJson);
  }
}

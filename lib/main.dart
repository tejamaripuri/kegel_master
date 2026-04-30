import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kegel_master/app.dart';
import 'package:kegel_master/features/onboarding/application/onboarding_gate.dart';
import 'package:kegel_master/features/onboarding/data/onboarding_persistence.dart';
import 'package:kegel_master/features/onboarding/presentation/onboarding_scope.dart';
import 'package:kegel_master/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final OnboardingPersistence persistence =
      SharedPreferencesOnboardingPersistence(prefs);
  final OnboardingGate gate = OnboardingGate(persistence);
  await gate.load();
  final GoRouter router = createAppRouter(gate: gate);
  runApp(
    OnboardingScope(
      gate: gate,
      child: KegelMasterApp(router: router),
    ),
  );
}

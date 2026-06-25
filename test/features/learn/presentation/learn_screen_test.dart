import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kegel_master/core/services/shared_preferences_provider.dart';
import 'package:kegel_master/features/learn/application/learn_anatomy_track_controller.dart';
import 'package:kegel_master/features/learn/domain/learn_profile_signals.dart';
import 'package:kegel_master/features/learn/presentation/learn_screen.dart';
import 'package:kegel_master/features/onboarding/application/onboarding_gate.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_profile.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_snapshot.dart';
import 'package:kegel_master/features/onboarding/presentation/onboarding_scope.dart';
import 'package:kegel_master/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../fakes/fake_onboarding_persistence.dart';

OnboardingProfile _profile({GenderIdentity gender = GenderIdentity.male}) {
  return OnboardingProfile(
    gender: gender,
    primaryGoal: PrimaryGoal.preventionMaintenance,
    ageBand: AgeBand.age18to34,
    symptoms: const <Symptom>{Symptom.none},
    clinicalHistory: const <ClinicalHistory>{ClinicalHistory.none},
  );
}

Future<Widget> _learnHarness({
  required OnboardingSnapshot snapshot,
  Map<String, Object> initialPrefs = const <String, Object>{},
}) async {
  SharedPreferences.setMockInitialValues(initialPrefs);
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final FakeOnboardingPersistence persistence =
      FakeOnboardingPersistence(initial: snapshot);
  final OnboardingGate gate = OnboardingGate(persistence);
  await gate.load();

  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: OnboardingScope(
      gate: gate,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const LearnScreen(),
      ),
    ),
  );
}

Future<void> _tapWhenVisible(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  group('LearnScreen anatomy track section', () {
    testWidgets('shows disclaimer and foundation before anatomy section',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        await _learnHarness(
          snapshot: OnboardingSnapshot(
            onboardingComplete: true,
            catheterActive: false,
            profile: _profile(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Foundation'), findsOneWidget);
      expect(find.text('Anatomy track'), findsOneWidget);
      expect(
        find.text('What the pelvic floor does'),
        findsOneWidget,
      );
    });

    testWidgets('male profile defaults to male-typical how-to body',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        await _learnHarness(
          snapshot: OnboardingSnapshot(
            onboardingComplete: true,
            catheterActive: false,
            profile: _profile(gender: GenderIdentity.male),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('For male-typical pelvic anatomy'),
        findsOneWidget,
      );
      expect(find.text('Male-typical pelvic cues'), findsOneWidget);
    });

    testWidgets('non-binary profile prompts track selection without body',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        await _learnHarness(
          snapshot: OnboardingSnapshot(
            onboardingComplete: true,
            catheterActive: false,
            profile: _profile(gender: GenderIdentity.nonBinary),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Pick the anatomy track that matches the pelvic cues you want to work with.',
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining('For male-typical pelvic anatomy'),
        findsNothing,
      );
      expect(
        find.textContaining('For female-typical pelvic anatomy'),
        findsNothing,
      );
    });

    testWidgets('non-binary user can select a track and see matching body',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        await _learnHarness(
          snapshot: OnboardingSnapshot(
            onboardingComplete: true,
            catheterActive: false,
            profile: _profile(gender: GenderIdentity.nonBinary),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _tapWhenVisible(tester, find.text('Female-typical pelvic cues'));

      expect(
        find.textContaining('For female-typical pelvic anatomy'),
        findsOneWidget,
      );
    });

    testWidgets('binary user can override suggested track',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        await _learnHarness(
          snapshot: OnboardingSnapshot(
            onboardingComplete: true,
            catheterActive: false,
            profile: _profile(gender: GenderIdentity.male),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _tapWhenVisible(tester, find.text('Female-typical pelvic cues'));

      expect(
        find.textContaining('For female-typical pelvic anatomy'),
        findsOneWidget,
      );
      expect(
        find.textContaining('For male-typical pelvic anatomy'),
        findsNothing,
      );
    });

    testWidgets('privacy expansion hides tactile copy until expanded',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        await _learnHarness(
          snapshot: OnboardingSnapshot(
            onboardingComplete: true,
            catheterActive: false,
            profile: _profile(gender: GenderIdentity.male),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Optional: tactile check'), findsOneWidget);
      expect(
        find.textContaining('lightly press the perineum'),
        findsNothing,
      );

      await _tapWhenVisible(tester, find.text('Optional: tactile check'));

      expect(
        find.textContaining('lightly press the perineum'),
        findsOneWidget,
      );
    });

    testWidgets('persists explicit anatomy track choice',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        await _learnHarness(
          snapshot: OnboardingSnapshot(
            onboardingComplete: true,
            catheterActive: false,
            profile: _profile(gender: GenderIdentity.nonBinary),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _tapWhenVisible(tester, find.text('Male-typical pelvic cues'));

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString(learnAnatomyTrackPreferenceKey),
        AnatomyTrack.maleTypical.name,
      );
    });
  });

  group('LearnScreen dos and don\'ts section', () {
    testWidgets('shows dos and don\'ts after anatomy with check and cross icons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        await _learnHarness(
          snapshot: OnboardingSnapshot(
            onboardingComplete: true,
            catheterActive: false,
            profile: _profile(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Anatomy track'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Dos and don\'ts'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Dos and don\'ts'), findsOneWidget);
      expect(
        find.textContaining('Let the pelvic floor fully release'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Do not push through sharp'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.check_circle_outline), findsNWidgets(4));
      expect(find.byIcon(Icons.cancel_outlined), findsNWidgets(4));
    });
  });
}

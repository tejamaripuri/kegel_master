import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kegel_master/features/onboarding/application/onboarding_gate.dart';
import 'package:kegel_master/features/onboarding/presentation/onboarding_scope.dart';
import 'package:kegel_master/features/progress/data/in_memory_progress_stores.dart';
import 'package:kegel_master/features/progress/presentation/progress_scope.dart';
import 'package:kegel_master/router/app_router.dart';

import 'package:kegel_master/app.dart';
import 'fakes/fake_onboarding_persistence.dart';

Future<GoRouter> _pumpAppWithCompletedOnboarding(WidgetTester tester) async {
  final FakeOnboardingPersistence persistence = FakeOnboardingPersistence();
  final OnboardingGate gate = OnboardingGate(persistence);
  await gate.load();
  final GoRouter router = createAppRouter(gate: gate);
  final InMemoryUserPreferencesStore userPreferences =
      InMemoryUserPreferencesStore();
  await userPreferences.ensureSeedRow();
  await tester.pumpWidget(
    OnboardingScope(
      gate: gate,
      child: ProgressScope(
        sessionHistory: InMemorySessionHistoryStore(),
        userPreferences: userPreferences,
        child: KegelMasterApp(router: router),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  group('KegelMasterApp', () {
    testWidgets('shows NavigationBar and Home content by default', (WidgetTester tester) async {
      await _pumpAppWithCompletedOnboarding(tester);

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Start a guided session when you are ready.'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Start session'), findsOneWidget);
    });

    testWidgets('Learn tab shows learn screen body', (WidgetTester tester) async {
      await _pumpAppWithCompletedOnboarding(tester);
      await tester.tap(find.byIcon(Icons.menu_book_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Guides and techniques — coming soon.'), findsOneWidget);
    });

    testWidgets('Progress tab shows progress and achievements sections', (WidgetTester tester) async {
      await _pumpAppWithCompletedOnboarding(tester);
      await tester.tap(find.byIcon(Icons.insights_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Your progress'), findsOneWidget);
      expect(find.text('Achievements'), findsOneWidget);
      expect(find.text('Badges and milestones — coming soon.'), findsOneWidget);
    });

    testWidgets('Settings tab shows reset onboarding', (WidgetTester tester) async {
      await _pumpAppWithCompletedOnboarding(tester);
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Reset onboarding'), findsOneWidget);
    });

    testWidgets('switching back to Home shows home body again', (WidgetTester tester) async {
      await _pumpAppWithCompletedOnboarding(tester);
      await tester.tap(find.byIcon(Icons.menu_book_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.home_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Start a guided session when you are ready.'), findsOneWidget);
    });

    testWidgets('Start session pushes full-screen session without NavigationBar', (WidgetTester tester) async {
      await _pumpAppWithCompletedOnboarding(tester);
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Start session'));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('Session'), findsOneWidget);
    });

    testWidgets('system back on active session shows end confirmation', (WidgetTester tester) async {
      await _pumpAppWithCompletedOnboarding(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Start session'));
      await tester.pumpAndSettle();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      final Finder dialog = find.byType(AlertDialog);
      expect(dialog, findsOneWidget);
      expect(
        find.descendant(of: dialog, matching: find.text('End session early?')),
        findsOneWidget,
      );
    });

    testWidgets('router.go shows Learn tab without tapping NavigationBar', (WidgetTester tester) async {
      final GoRouter router = await _pumpAppWithCompletedOnboarding(tester);

      expect(find.text('Start a guided session when you are ready.'), findsOneWidget);

      router.go('/learn');
      await tester.pumpAndSettle();

      expect(find.text('Guides and techniques — coming soon.'), findsOneWidget);
    });

    testWidgets('router.go to / redirects to Home content', (WidgetTester tester) async {
      final GoRouter router = await _pumpAppWithCompletedOnboarding(tester);

      router.go('/');
      await tester.pumpAndSettle();

      expect(find.text('Start a guided session when you are ready.'), findsOneWidget);
    });

    testWidgets('router.go(/session) opens session without NavigationBar', (WidgetTester tester) async {
      final GoRouter router = await _pumpAppWithCompletedOnboarding(tester);

      router.go('/session');
      await tester.pumpAndSettle();

      expect(find.text('Session'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('unknown location shows not found and Go home navigates to Home', (WidgetTester tester) async {
      final GoRouter router = await _pumpAppWithCompletedOnboarding(tester);

      router.go('/this-route-does-not-exist');
      await tester.pumpAndSettle();

      expect(find.text('No route for this location.'), findsOneWidget);

      await tester.tap(find.text('Go home'));
      await tester.pumpAndSettle();

      expect(find.text('Start a guided session when you are ready.'), findsOneWidget);
    });
  });
}

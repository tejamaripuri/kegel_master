import 'package:kegel_master/features/progress/application/session_history_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:kegel_master/features/onboarding/application/onboarding_gate.dart';
import 'package:kegel_master/features/onboarding/presentation/onboarding_scope.dart';
import 'package:kegel_master/features/progress/data/in_memory_progress_stores.dart';
import 'package:kegel_master/features/progress/presentation/progress_scope.dart';
import 'package:kegel_master/router/app_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegel_master/core/services/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kegel_master/app.dart';
import 'fakes/fake_onboarding_persistence.dart';
import 'package:kegel_master/core/services/notification_service.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationService extends Mock implements NotificationService {}

Future<GoRouter> _pumpAppWithCompletedOnboarding(WidgetTester tester) async {
  final FakeOnboardingPersistence persistence = FakeOnboardingPersistence();
  final OnboardingGate gate = OnboardingGate(persistence);
  await gate.load();
  final GoRouter router = createAppRouter(gate: gate);
  final InMemoryUserPreferencesStore userPreferences =
      InMemoryUserPreferencesStore();
  await userPreferences.ensureSeedRow();
  
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  final mockNotificationService = MockNotificationService();
  when(() => mockNotificationService.registerTapHandler(any())).thenAnswer((_) {});
  final sessionHistory = InMemorySessionHistoryStore();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        notificationServiceProvider.overrideWithValue(mockNotificationService),
        sessionHistoryStoreProvider.overrideWithValue(sessionHistory),
      ],
      child: OnboardingScope(
        gate: gate,
        child: ProgressScope(
          sessionHistory: sessionHistory,
          userPreferences: userPreferences,
          child: KegelMasterApp(router: router),
        ),
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
      expect(find.text('Training calendar'), findsOneWidget);
      expect(find.byType(TableCalendar<Object>), findsOneWidget);
      expect(find.text('Current streak: 0 days'), findsOneWidget);
      for (var i = 0; i < 25; i++) {
        if (find.text('Achievements').evaluate().isNotEmpty) break;
        await tester.drag(find.text('Your progress'), const Offset(0, -350));
        await tester.pump();
      }
      await tester.pumpAndSettle();
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

    testWidgets('notification tap routes to Home screen', (WidgetTester tester) async {
      final FakeOnboardingPersistence persistence = FakeOnboardingPersistence();
      final OnboardingGate gate = OnboardingGate(persistence);
      await gate.load();
      final GoRouter router = createAppRouter(gate: gate);
      final InMemoryUserPreferencesStore userPreferences =
          InMemoryUserPreferencesStore();
      await userPreferences.ensureSeedRow();
      
      final prefs = await SharedPreferences.getInstance();
      final mockNotificationService = MockNotificationService();
      
      void Function()? registeredCallback;
      when(() => mockNotificationService.registerTapHandler(any())).thenAnswer((invocation) {
        registeredCallback = invocation.positionalArguments[0] as void Function();
      });
      final sessionHistory = InMemorySessionHistoryStore();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            notificationServiceProvider.overrideWithValue(mockNotificationService),
            sessionHistoryStoreProvider.overrideWithValue(sessionHistory),
          ],
          child: OnboardingScope(
            gate: gate,
            child: ProgressScope(
              sessionHistory: sessionHistory,
              userPreferences: userPreferences,
              child: KegelMasterApp(router: router),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate away from home
      router.go('/settings');
      await tester.pumpAndSettle();
      expect(find.text('Reset onboarding'), findsOneWidget);

      // Simulate notification tap
      expect(registeredCallback, isNotNull);
      registeredCallback!();
      await tester.pumpAndSettle();

      // Should be back at Home screen
      expect(find.text('Start a guided session when you are ready.'), findsOneWidget);
    });
  });
}

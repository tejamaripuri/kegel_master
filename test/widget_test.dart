import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kegel_master/router/app_router.dart';

import 'package:kegel_master/app.dart';

void main() {
  group('KegelMasterApp', () {
    testWidgets('shows NavigationBar and Home content by default', (WidgetTester tester) async {
      await tester.pumpWidget(const KegelMasterApp());

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Start a guided session when you are ready.'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Start session'), findsOneWidget);
    });

    testWidgets('Learn tab shows learn screen body', (WidgetTester tester) async {
      await tester.pumpWidget(const KegelMasterApp());
      await tester.tap(find.byIcon(Icons.menu_book_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Guides and techniques — coming soon.'), findsOneWidget);
    });

    testWidgets('Progress tab shows progress and achievements sections', (WidgetTester tester) async {
      await tester.pumpWidget(const KegelMasterApp());
      await tester.tap(find.byIcon(Icons.insights_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Your progress'), findsOneWidget);
      expect(find.text('Achievements'), findsOneWidget);
      expect(find.text('Badges and milestones — coming soon.'), findsOneWidget);
    });

    testWidgets('Settings tab shows settings body', (WidgetTester tester) async {
      await tester.pumpWidget(const KegelMasterApp());
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Preferences — coming soon.'), findsOneWidget);
    });

    testWidgets('switching back to Home shows home body again', (WidgetTester tester) async {
      await tester.pumpWidget(const KegelMasterApp());
      await tester.tap(find.byIcon(Icons.menu_book_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.home_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Start a guided session when you are ready.'), findsOneWidget);
    });

    testWidgets('Start session pushes full-screen session without NavigationBar', (WidgetTester tester) async {
      await tester.pumpWidget(const KegelMasterApp());
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Start session'));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('Session'), findsWidgets);
    });

    testWidgets('router.go shows Learn tab without tapping NavigationBar', (WidgetTester tester) async {
      final GoRouter router = createAppRouter();
      await tester.pumpWidget(KegelMasterApp(router: router));

      expect(find.text('Start a guided session when you are ready.'), findsOneWidget);

      router.go('/learn');
      await tester.pumpAndSettle();

      expect(find.text('Guides and techniques — coming soon.'), findsOneWidget);
    });

    testWidgets('router.go to / redirects to Home content', (WidgetTester tester) async {
      final GoRouter router = createAppRouter();
      await tester.pumpWidget(KegelMasterApp(router: router));

      router.go('/');
      await tester.pumpAndSettle();

      expect(find.text('Start a guided session when you are ready.'), findsOneWidget);
    });

    testWidgets('unknown location shows not found and Go home navigates to Home', (WidgetTester tester) async {
      final GoRouter router = createAppRouter();
      await tester.pumpWidget(KegelMasterApp(router: router));

      router.go('/this-route-does-not-exist');
      await tester.pumpAndSettle();

      expect(find.text('No route for this location.'), findsOneWidget);

      await tester.tap(find.text('Go home'));
      await tester.pumpAndSettle();

      expect(find.text('Start a guided session when you are ready.'), findsOneWidget);
    });
  });
}

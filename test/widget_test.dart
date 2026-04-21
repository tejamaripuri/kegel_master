import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kegel_master/app.dart';

void main() {
  group('KegelMasterApp', () {
    testWidgets('shows NavigationBar and Home content by default', (WidgetTester tester) async {
      await tester.pumpWidget(const KegelMasterApp());

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Start or resume your session — coming soon.'), findsOneWidget);
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

      expect(find.text('Start or resume your session — coming soon.'), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';
import 'package:kegel_master/features/session/presentation/session_screen.dart';

Widget _wrapWithPushRoute(SessionConfig config) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: Builder(
          builder: (BuildContext context) {
            return FilledButton(
              onPressed: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => SessionScreen(config: config),
                  ),
                );
              },
              child: const Text('Open session'),
            );
          },
        ),
      ),
    ),
  );
}

void main() {
  final SessionConfig testConfig = SessionConfig(
    squeezeSeconds: 5,
    relaxSeconds: 5,
    bufferBetweenSetsSeconds: 0,
    repsPerSet: 2,
    targetSets: 2,
  );

  testWidgets('initial UI shows Squeeze and Skip/End controls', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SessionScreen(config: testConfig),
      ),
    );

    expect(find.text('Session'), findsOneWidget);
    expect(find.text('Squeeze'), findsOneWidget);
    expect(find.text('5s'), findsOneWidget);
    expect(find.text('Set 1 of 2'), findsOneWidget);
    expect(find.text('Rep 1 of 2'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('End session'), findsOneWidget);
  });

  testWidgets('tapping Skip advances to Relax', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SessionScreen(config: testConfig),
      ),
    );

    await tester.tap(find.text('Skip'));
    await tester.pump();

    expect(find.text('Relax'), findsOneWidget);
  });

  testWidgets('End session opens confirmation dialog then confirm closes screen', (WidgetTester tester) async {
    await tester.pumpWidget(_wrapWithPushRoute(testConfig));

    await tester.tap(find.text('Open session'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('End session'));
    await tester.pumpAndSettle();

    final Finder dialog = find.byType(AlertDialog);
    expect(dialog, findsOneWidget);
    expect(
      find.descendant(of: dialog, matching: find.text('End session early?')),
      findsOneWidget,
    );
    await tester.tap(
      find.descendant(
        of: dialog,
        matching: find.widgetWithText(FilledButton, 'End'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Open session'), findsOneWidget);
  });

  testWidgets('End session dialog Cancel dismisses without popping route', (WidgetTester tester) async {
    await tester.pumpWidget(_wrapWithPushRoute(testConfig));

    await tester.tap(find.text('Open session'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('End session'));
    await tester.pumpAndSettle();

    final Finder dialog = find.byType(AlertDialog);
    expect(dialog, findsOneWidget);
    await tester.tap(
      find.descendant(
        of: dialog,
        matching: find.widgetWithText(TextButton, 'Cancel'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Open session'), findsNothing);
    expect(find.text('Session'), findsOneWidget);
    expect(find.text('End session'), findsOneWidget);
  });

  testWidgets('Done state renders and close action pops', (WidgetTester tester) async {
    final SessionConfig quickDoneConfig = SessionConfig(
      squeezeSeconds: 1,
      relaxSeconds: 1,
      bufferBetweenSetsSeconds: 0,
      repsPerSet: 1,
      targetSets: 1,
    );

    await tester.pumpWidget(_wrapWithPushRoute(quickDoneConfig));

    await tester.tap(find.text('Open session'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pump();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Session complete.'), findsOneWidget);
    expect(find.text('Back to home'), findsOneWidget);

    await tester.tap(find.text('Back to home'));
    await tester.pumpAndSettle();

    expect(find.text('Open session'), findsOneWidget);
  });
}

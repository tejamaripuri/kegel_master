import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';
import 'package:kegel_master/features/session/presentation/session_screen.dart';

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

    expect(find.text('Squeeze'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
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
}

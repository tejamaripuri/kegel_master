import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kegel_master/core/services/shared_preferences_provider.dart';
import 'package:kegel_master/core/theme/theme_mode_controller.dart';
import 'package:kegel_master/features/settings/presentation/settings_screen.dart';

void main() {
  group('SettingsScreen', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    Widget createWidgetUnderTest() {
      return ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: Consumer(
          builder: (context, ref, child) {
            final themeMode = ref.watch(themeModeControllerProvider);
            return MaterialApp(
              themeMode: themeMode,
              home: const SettingsScreen(),
            );
          },
        ),
      );
    }

    testWidgets('renders SegmentedButton with Light/Dark/System options', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(SegmentedButton<ThemeMode>), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('tapping Dark option changes the theme mode in controller', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap on Dark
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      // Verify preference was saved
      expect(prefs.getString('themeMode'), 'dark');
    });
  });
}

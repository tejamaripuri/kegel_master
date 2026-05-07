import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kegel_master/core/services/shared_preferences_provider.dart';
import 'package:kegel_master/core/theme/theme_mode_controller.dart';

void main() {
  group('ThemeModeController', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    ProviderContainer createContainer() {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('initializes with system if no preference is saved', () {
      final container = createContainer();
      final mode = container.read(themeModeControllerProvider);
      expect(mode, ThemeMode.system);
    });

    test('initializes with saved preference', () async {
      SharedPreferences.setMockInitialValues({'themeMode': 'dark'});
      prefs = await SharedPreferences.getInstance();
      
      final container = createContainer();
      final mode = container.read(themeModeControllerProvider);
      expect(mode, ThemeMode.dark);
    });

    test('setThemeMode updates state and persists preference', () {
      final container = createContainer();
      
      container.read(themeModeControllerProvider.notifier).setThemeMode(ThemeMode.light);
      
      final mode = container.read(themeModeControllerProvider);
      expect(mode, ThemeMode.light);
      expect(prefs.getString('themeMode'), 'light');
    });
  });
}

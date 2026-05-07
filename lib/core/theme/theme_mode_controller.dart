import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegel_master/core/services/shared_preferences_provider.dart';

const String _themeModeKey = 'themeMode';

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final themeStr = prefs.getString(_themeModeKey);
    return _parseThemeMode(themeStr);
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(_themeModeKey, mode.name);
  }

  ThemeMode _parseThemeMode(String? themeStr) {
    switch (themeStr) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}

final themeModeControllerProvider = NotifierProvider<ThemeModeController, ThemeMode>(() {
  return ThemeModeController();
});

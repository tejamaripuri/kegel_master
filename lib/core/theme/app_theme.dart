import 'package:flutter/material.dart';

class AppTheme {
  static const Color _primarySeed = Colors.deepPurple;

  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primarySeed,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primarySeed,
      brightness: Brightness.dark,
      // Deep Slate/Charcoal palette
      surface: const Color(0xFF121212),
      surfaceContainerHighest: const Color(0xFF1E1E1E),
    ),
    useMaterial3: true,
  );
}

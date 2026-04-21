import 'package:flutter/material.dart';

import 'package:kegel_master/features/shell/main_navigation_shell.dart';

class KegelMasterApp extends StatelessWidget {
  const KegelMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kegel Master',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainNavigationShell(),
    );
  }
}

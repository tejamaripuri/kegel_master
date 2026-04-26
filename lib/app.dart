import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kegel_master/router/app_router.dart';

class KegelMasterApp extends StatelessWidget {
  const KegelMasterApp({super.key, this.router});

  final GoRouter? router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kegel Master',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router ?? defaultAppRouter,
    );
  }
}

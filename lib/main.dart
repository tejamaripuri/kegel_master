import 'package:flutter/material.dart';

void main() {
  runApp(const KegelMasterApp());
}

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
      home: Scaffold(
        appBar: AppBar(title: const Text('Kegel Master')),
        body: const Center(child: Text('Kegel exercises — coming soon.')),
      ),
    );
  }
}

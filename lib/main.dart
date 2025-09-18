// lib/main.dart
import 'package:appcounter/pages/intro_pages.dart';
import 'package:flutter/material.dart';
import 'app_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the bootstrap helper to create the repository and seed data
    final appState = AppState.bootstrap();

    return AppStateScope(
      notifier: appState,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Watch Shop',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
          useMaterial3: true,
        ),
        home: IntroPages(),
      ),
    );
  }
}

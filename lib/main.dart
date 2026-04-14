import 'package:flutter/material.dart';
import 'screens/title_screen.dart';

void main() {
  runApp(const SinariApp());
}

class SinariApp extends StatelessWidget {
  const SinariApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '深淵の図書館',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A0A2E),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF050510),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFD4C5A9)),
          bodyMedium: TextStyle(color: Color(0xFFD4C5A9)),
        ),
      ),
      home: const TitleScreen(),
    );
  }
}

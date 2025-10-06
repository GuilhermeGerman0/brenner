import 'package:brenner/pages/login_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const BrennerApp());
}

class BrennerApp extends StatelessWidget {
  const BrennerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brenner App',
      debugShowCheckedModeBanner: false,

      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.black,
      ),

      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),

      home: LoginScreen(),
    );
  }
}

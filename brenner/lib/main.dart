import 'package:brenner/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';

void main() {
  runApp(const BrennerApp());
}

class BrennerApp extends StatelessWidget {
  const BrennerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brenner App',
      theme: ThemeData(primarySwatch: Colors.teal),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

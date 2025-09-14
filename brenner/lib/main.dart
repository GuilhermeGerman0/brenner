import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';

void main() {
  runApp(BrennerApp());
}

class BrennerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brenner App',
      theme: ThemeData(primarySwatch: Colors.teal),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
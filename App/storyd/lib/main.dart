import 'package:flutter/material.dart';
import 'package:storyd/screens/splash.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Storyd',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
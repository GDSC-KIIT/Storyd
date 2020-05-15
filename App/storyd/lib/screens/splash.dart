import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Center(
            child: Text(
              "Storyd",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 55,
                fontFamily: "CircularStd",
                letterSpacing: 2,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.4,
              child: Image.asset("assets/storyd-splash.png"),
            ),
          ),
        ],
      ),
    );
  }
}

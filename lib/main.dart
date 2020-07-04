import 'package:barber/inscription/login.dart';
import 'package:flutter/material.dart';

void main() => runApp(
      Myapp(),
    );

class Myapp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: new ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.red,
        primaryColor: const Color(0xFF6b9080),
        accentColor: const Color(0xFFf6fff8),
        canvasColor: const Color(0xFFa4c3b2),
        fontFamily: 'Merriweather',
      ),
      home: SignIn(),
    );
  }
}

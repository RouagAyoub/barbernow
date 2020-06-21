
import 'package:flutter/material.dart';
import 'package:barber/login.dart';

void main() => runApp(
    Myapp(),
);
class Myapp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SignIn(),
    );
  }
}
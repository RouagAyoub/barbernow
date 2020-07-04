import 'package:barber/inscription/login.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double rightleft = 100;
  double bottom;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    bottom = height / 6;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/dokhol2.jpg"),
              fit: BoxFit.fill,
            ),
          ),
        ),
        Positioned(
          right: rightleft,
          left: rightleft,
          bottom: bottom,
          child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => SignIn()));
              },
              child: Image(
                image: AssetImage('assets/dokholbutto.png'),
                fit: BoxFit.contain,
                height: 100,
              )),
        ),
      ],
    );
  }
}

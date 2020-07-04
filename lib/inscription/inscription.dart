import 'package:barber/authentication/authverify.dart';
import 'package:barber/inscription/barberinsc.dart';
import 'package:barber/msg/toasting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'login.dart';

class Inscr extends StatefulWidget {
  @override
  Inscription createState() => Inscription();
}

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
enum SingingCharacter { barber, client }

class Inscription extends State<Inscr> {
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formkey = GlobalKey<FormState>();
  TextEditingController _username = TextEditingController();
  TextEditingController _userpass = TextEditingController();
  TextEditingController _firstname = TextEditingController();
  SingingCharacter _character = SingingCharacter.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Form(
                key: _formkey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _firstname,
                      decoration: InputDecoration(
                        hintText: 'full name',
                      ),
                      validator: (value) {
                        if (value.length < 4) {
                          return 'full name is too short';
                        }
                      },
                    ),
                    TextFormField(
                      controller: _username,
                      decoration: InputDecoration(
                        hintText: 'Email',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Email or number recuired';
                        }
                      },
                    ),
                    TextFormField(
                      controller: _userpass,
                      decoration: InputDecoration(
                        hintText: 'Password',
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Password recuired';
                        }
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Password confirmation',
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value != _userpass.text) {
                          return 'confirmation does not match';
                        }
                      },
                    ),
                    ListTile(
                      title: const Text('Client'),
                      leading: Radio(
                        value: SingingCharacter.client,
                        groupValue: _character,
                        onChanged: (SingingCharacter value) {
                          setState(() {
                            _character = value;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('Barber'),
                      leading: Radio(
                        value: SingingCharacter.barber,
                        groupValue: _character,
                        onChanged: (SingingCharacter value) {
                          setState(() {
                            _character = value;
                          });
                        },
                      ),
                    ),
                    RaisedButton(
                      color: Colors.red,
                      child: Text('Continue'),
                      onPressed: () async {
                        try {
                          if (_formkey.currentState.validate()) {
                            AuthProvider()
                                .verifyPhoneNumber(context, _username.text);
                            /*
                            if (_character == SingingCharacter.barber) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Barbersigncomplter(),
                                      settings: RouteSettings(
                                        arguments: <String, String>{
                                          'name': _firstname.text,
                                          'email': _username.text,
                                          'password': _userpass.text,
                                        },
                                      )));
                            } else if (_character == SingingCharacter.client) {
                              try {
                                var result = (await FirebaseAuth.instance
                                        .createUserWithEmailAndPassword(
                                            email: _username.text,
                                            password: _username.text))
                                    .user;
                                Firestore.instance
                                    .collection('users')
                                    .document(result.uid)
                                    .setData({
                                  'email': result.email,
                                  'name': _firstname.text,
                                });
                                Toasting()
                                    .showToast("account created succesfully");
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignIn()));
                              } catch (e) {
                                Toasting().showToast(e.toString());
                              }
                            }
*/
                            //////////////////////////////////   5   //////////////////////////////////////////

                          }
                        } catch (e) {
                          if (e.toString().contains('6 characters')) {
                            Toasting().showToast(
                                'Password should be at least 6 characters');
                          } else if (e
                              .toString()
                              .contains('ERROR_NETWORK_REQUEST_FAILED')) {
                            Toasting().showToast(
                                'Password should be at least 6 characters');
                          } else {
                            Toasting().showToast(
                                'The email address is badly formatted');
                          }
                        }
                      },
                    )
                  ],
                )),
          ),
        ));
  }
}

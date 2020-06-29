import 'package:barber/appforclient.dart';
import 'package:barber/inscription.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formkey = GlobalKey<FormState>();
  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _passcontroller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(
        message: 'LOADING...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('LOGIN'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle),
              tooltip: 'creat account',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Inscr()),
                );
              },
            )
          ],
        ),
        resizeToAvoidBottomPadding: false,
        body: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(20, 100, 20, 10),
              child: Form(
                  key: _formkey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _emailcontroller,
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
                        controller: _passcontroller,
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
                      RaisedButton(
                        color: Color(0xFFf6fff8),
                        child: Text('Login'),
                        onPressed: () async {
                          try {
                            if (_formkey.currentState.validate()) {
                              pr.show();
                              var result =
                                  (await _auth.signInWithEmailAndPassword(
                                          email: _emailcontroller.text.trim(),
                                          password: _passcontroller.text))
                                      .user;
                              if (result != null) {
                                pr.hide();
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Appforclient()));
                              }
                            }
                          } catch (e) {
                            pr.hide();
                            _scaffoldKey.currentState.showSnackBar(
                                SnackBar(content: Text(e.toString())));
                            if (e.toString().contains('ERROR_USER_NOT_FOUND')) {
                              _scaffoldKey.currentState.showSnackBar(
                                  SnackBar(content: Text('USER_NOT_FOUND')));
                            } else if (e
                                .toString()
                                .contains('ERROR_NETWORK_REQUEST_FAILED')) {
                              _scaffoldKey.currentState.showSnackBar(
                                  SnackBar(content: Text('CONNEXION_FAILED')));
                            } else if (e
                                .toString()
                                .contains('ERROR_WRONG_PASSWORD')) {
                              showToast('WRONG_PASSWORD');
                            } else if (e
                                .toString()
                                .contains('TOO_MANY_REQUESTS')) {
                              showToast(
                                  'TOO_MANY_REQUESTS Please try again later');
                            } else {
                              showToast(e.toString());
                            }
                          }
                        },
                      ),
                    ],
                  )),
            )
          ],
        ));
  }

  void showToast(message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}

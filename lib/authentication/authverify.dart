import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  static const LOGGED_IN = "loggedIn";
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;

  // Firestore _firestore = Firestore.instance;

  TextEditingController phoneNo;
  String smsOTP;
  String verificationId;
  String errorMessage = '';
  bool loggedIn;
  bool loading = false;

  Future<void> verifyPhoneNumber(BuildContext context, String number) async {
    final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      smsOTPDialog(context).then((value) {
        print('sign in');
      });
    };
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: number.trim(), // PHONE NUMBER TO SEND OTP
          codeAutoRetrievalTimeout: (String verId) {
            //Starts the phone number verification process for the given phone number.
            //Either sends an SMS with a 6 digit code to the phone number specified, or sign's the user in and [verificationCompleted] is called.
            this.verificationId = verId;
          },
          codeSent:
              smsOTPSent, // WHEN CODE SENT THEN WE OPEN DIALOG TO ENTER OTP.
          timeout: const Duration(seconds: 20),
          verificationCompleted: (AuthCredential phoneAuthCredential) {
            print(phoneAuthCredential.toString() + "lets make this work");
          },
          verificationFailed: (AuthException exceptio) {
            print('${exceptio.message} + something is wrong');
          });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<bool> smsOTPDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Enter SMS Code'),
            content: Container(
              height: 85,
              child: Column(children: [
                TextField(
                  onChanged: (value) {
                    this.smsOTP = value;
                  },
                ),
              ]),
            ),
            contentPadding: EdgeInsets.all(10),
            actions: <Widget>[
              FlatButton(
                child: Text('Done'),
                onPressed: () async {
                  loading = true;
                  notifyListeners();
                  _auth.currentUser().then((user) async {
                    loading = true;
                    notifyListeners();
                    Navigator.of(context).pop();
                    loading = false;
                  });
                },
              )
            ],
          );
        });
  }
}

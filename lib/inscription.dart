import 'package:barber/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Inscr extends StatefulWidget
{
  @override
  Inscription createState() => Inscription();
}
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
class Inscription extends State<Inscr>
{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formkey = GlobalKey<FormState>();
  TextEditingController _username = TextEditingController();
  TextEditingController _userpass = TextEditingController();
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold
    (
      key: _scaffoldKey,
      appBar:AppBar(),
      body:Column(
        children:<Widget>
        [Container
          (padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Form
            (key: _formkey,
              child: Column
            (children:
              [
                TextFormField(
                 controller: _username,
                 decoration: InputDecoration(
                   hintText: 'Email',
                   
                 ),
                 
                 validator: (value) {
                   if(value.isEmpty){
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
                 validator: (value){
                   if(value.isEmpty){
                     return 'Password recuired';
                   }
                 },
              ),
              TextFormField(
                 decoration: InputDecoration(
                   hintText: 'Password confirmation',
                 ),
                 obscureText: true,
                 validator: (value){
                   if(value != _userpass.text){
                     return 'confirmation does not match';
                   }
                 },
              ),
              RaisedButton(
                color: Colors.red,
                child: Text('SIGN_UP'),
                onPressed: () async{
                  try{
                    if(_formkey.currentState.validate())
                    {
                    var result =(await  _auth.createUserWithEmailAndPassword(email: _username.text, password: _userpass.text)).user;
                      if(result !=null)
                      {
                        Firestore.instance.collection('users').document(result.uid).setData(
                          {
                            'email':result.email,
                            'passw':result.email
                          }
                        );
                        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("account created succesfully")));
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()));
                      }
                    }
                  }catch(e)
                  {
                    print(e.toString());
                    if(e.toString().contains('6 characters'))
                    {
                      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Password should be at least 6 characters')));
                    }else
                    if(e.toString().contains('ERROR_NETWORK_REQUEST_FAILED'))
                    {
                      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Password should be at least 6 characters')));
                    }else{print(e.toString());
                    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('The email address is badly formatted')));
                   }
                  
                  }
              },
              ),

              ],
            )
            ),
          )
        ],
      ),
    );

  }
  
}
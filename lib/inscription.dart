import 'package:barber/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

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
                                _scaffoldKey.currentState.showSnackBar(SnackBar(
                                    content:
                                        Text("account created succesfully")));
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignIn()));
                              } catch (e) {
                                showToast(e.toString());
                              }
                            }

                            //////////////////////////////////   5   //////////////////////////////////////////

                          }
                        } catch (e) {
                          print(e.toString());
                          if (e.toString().contains('6 characters')) {
                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text(
                                    'Password should be at least 6 characters')));
                          } else if (e
                              .toString()
                              .contains('ERROR_NETWORK_REQUEST_FAILED')) {
                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text(
                                    'Password should be at least 6 characters')));
                          } else {
                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text(
                                    'The email address is badly formatted')));
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

void showToast(message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 2,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}

class Barbersigncomplter extends StatefulWidget {
  @override
  _Barbersignin createState() => _Barbersignin();
}

class _Barbersignin extends State<Barbersigncomplter> {
  GoogleMapController _controller;
  Position position;
  Placemark placeMark;
  Widget _child;

  Future<void> getLocation() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.location);

    if (permission == PermissionStatus.denied) {
      await PermissionHandler()
          .requestPermissions([PermissionGroup.locationAlways]);
    }

    var geolocator = Geolocator();

    GeolocationStatus geolocationStatus =
        await geolocator.checkGeolocationPermissionStatus();

    switch (geolocationStatus) {
      case GeolocationStatus.denied:
        showToast('denied');
        break;
      case GeolocationStatus.disabled:
        showToast('disabled');
        break;
      case GeolocationStatus.restricted:
        showToast('restricted');
        break;
      case GeolocationStatus.unknown:
        showToast('unknown');
        break;
      case GeolocationStatus.granted:
        showToast('Access granted');
        _getCurrentLocation();
    }
  }

  Set<Marker> _createMarker() {
    return <Marker>[
      Marker(
          markerId: MarkerId('home'),
          position: LatLng(position.latitude, position.longitude),
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: 'Current Location'))
    ].toSet();
  }

  /* void showToast(message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
*/
  @override
  void initState() {
    getLocation();
    super.initState();
  }

  void _getCurrentLocation() async {
    final Geolocator _geolocator = Geolocator();
    Position res = await Geolocator().getCurrentPosition();
    setState(() {
      position = res;
      _child = _mapWidget();
    });
    List<Placemark> newPlace =
        await _geolocator.placemarkFromCoordinates(res.latitude, res.longitude);
    placeMark = newPlace[0];
  }

  Widget _mapWidget() {
    return GoogleMap(
      mapType: MapType.normal,
      markers: _createMarker(),
      initialCameraPosition: CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 12.0,
      ),
      onMapCreated: (GoogleMapController controller) {
        _controller = controller;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Map idofbarb = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Google Map',
          textAlign: TextAlign.center,
          style: TextStyle(color: CupertinoColors.white),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: Container(child: _child)),
          Row(children: <Widget>[
            Expanded(
              child: FlatButton(
                onPressed: () async {
                  try {
                    var result = (await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                                email: idofbarb['email'].toString(),
                                password: idofbarb['password'].toString()))
                        .user;
                    Firestore.instance
                        .collection('barbers')
                        .document(result.uid)
                        .setData({
                      'email': result.email.toString(),
                      'name': idofbarb['name'],
                      'place': (placeMark.administrativeArea +
                              placeMark.locality +
                              placeMark.thoroughfare)
                          .toString(),
                      'posix': position.latitude,
                      'posiy': position.longitude,
                    });

                    _scaffoldKey.currentState.showSnackBar(
                        SnackBar(content: Text("account created succesfully")));
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => SignIn()));
                  } catch (e) {
                    showToast(e.toString());
                  }
                },
                child: Text('Continue'),
                color: Color(0xFF6b0000),
              ),
            ),
          ])
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _getCurrentLocation();
        },
        tooltip: 'location',
        child: Icon(Icons.my_location),
      ),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

/*  @override
  Widget build(BuildContext context) {

    
    return new Scaffold(
      appBar: AppBar(
        title: Text('data'),
      ),
      body: GoogleMap(
          initialCameraPosition: CameraPosition(
        target: LatLng(36.720839, 3.089857),
        zoom: 14.4746,
      )),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(100, 100, 100, 100),
        iconSize: 25,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_numbered),
            title: Text('LIST_WAITING'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            title: Text('DETAILS'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.place),
            title: Text('LOCALISATION'),
          ),
        ],
        currentIndex: 1,
        selectedItemColor: Colors.amber[800],
        //onTap: _onItemTapped,
      ),
    );
  }*/
}

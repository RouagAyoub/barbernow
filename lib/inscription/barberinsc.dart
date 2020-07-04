import 'package:barber/inscription/login.dart';
import 'package:barber/msg/getdatafrom.dart';
import 'package:barber/msg/toasting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

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
        Toasting().showToast('denied');
        break;
      case GeolocationStatus.disabled:
        Toasting().showToast('disabled');
        break;
      case GeolocationStatus.restricted:
        Toasting().showToast('restricted');
        break;
      case GeolocationStatus.unknown:
        Toasting().showToast('unknown');
        break;
      case GeolocationStatus.granted:
        Toasting().showToast('Access granted');
        _getCurrentLocation();
    }
  }

  /* Set<Marker> _createMarker() {
    return <Marker>[
      Marker(
          markerId: MarkerId('home'),
          position: LatLng(position.latitude, position.longitude),
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: 'Current Location'))
    ].toSet();
  }*/

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
      markers:
          Getdatafrom().createMarker(position.latitude, position.longitude),
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

                    Toasting().showToast("account created succesfully");
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => SignIn()));
                  } catch (e) {
                    Toasting().showToast(e.toString());
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
}

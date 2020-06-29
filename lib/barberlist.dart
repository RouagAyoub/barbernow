import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'dart:convert';

class Barber extends StatefulWidget {
  @override
  _Barberlist createState() => _Barberlist();
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

class _Barberlist extends State<Barber> {
  int _selectedIndex = 0;
  String username;
  DocumentSnapshot snapshot;
  final Completer c = new Completer();
  //DocumentSnapshot snapshots;

  /* Future snapshotin(documentation) async {
    snapshot = await Firestore.instance
        .collection('barbers')
        .document(documentation)
        .get();
    print(snapshot.data['posix']);
  }*/

  @override
  void initState() {
    super.initState();
    separate();
  }

  void separate() async {
    final String idofbarber = ModalRoute.of(context).settings.arguments;
    snapshot = await Firestore.instance
        .collection('barbers')
        .document(idofbarber)
        .get();
    if (snapshot == null) {
      separate();
    } else {}
  }

  /////////////////time/////////////////////
  String timeplace;
  void getdatetime() async {
    Response response =
        await get('http://worldtimeapi.org/api/timezone/Africa/Algiers');
    Map data = jsonDecode(response.body);
    String offset = data['utc_offset'].substring(1, 3);
    DateTime now = DateTime.parse(data['datetime']);
    now = now.add(Duration(hours: int.parse(offset)));
    timeplace = now.toString();
  }

  //////////////////time ////////////////////////

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Set<Marker> _createMarker(double posisionlat, double posotionlon) {
    return <Marker>[
      Marker(
          markerId: MarkerId('home'),
          position: LatLng(posisionlat, posotionlon),
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: 'Current Location'))
    ].toSet();
  }

  @override
  Widget build(BuildContext context) {
    final String idofbarber = ModalRoute.of(context).settings.arguments;

    //snapshots = snapshot as DocumentSnapshot;
    //snapshotin(idofbarber);

    final List<Widget> _children = [
      Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('barbers')
              .document(idofbarber)
              .collection('listewaiter')
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return new Center(
                  child: SpinKitRotatingCircle(
                    color: Colors.red[900],
                    size: 50.0,
                  ),
                );
              default:
                return new ListView(
                  children:
                      snapshot.data.documents.map((DocumentSnapshot document) {
                    return new ListTile(
                      title: new Text(
                        document['name'],
                        style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 25,
                            fontFamily: 'Digital-7'),
                      ),
                      subtitle: new Text(
                        document['time'],
                        style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 18,
                            fontFamily: 'Digital-7'),
                      ),
                    );
                  }).toList(),
                );
            }
          },
        ),
      ),
      Container(
        child: Text("details"),
      ),
      GoogleMap(
        mapType: MapType.normal,
        markers: _createMarker(snapshot.data['posix'], snapshot.data['posiy']),
        initialCameraPosition: CameraPosition(
          target: LatLng(snapshot.data['posix'], snapshot.data['posiy']),
          zoom: 12.0,
        ),
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('list client'),
      ),
      body: _children[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          getdatetime();
          try {
            final FirebaseUser user = await FirebaseAuth.instance.currentUser();
            DocumentSnapshot snapshot = await Firestore.instance
                .collection('users')
                .document(user.uid)
                .get();
            var inst = Firestore.instance
                .collection('barbers')
                .document(idofbarber)
                .collection('listewaiter')
                .document(user.uid);
            inst.setData({'time': timeplace, 'name': snapshot.data['name']});
          } catch (e) {
            showToast(e.toString());
          }
        },
        tooltip: 'add to list',
        child: Icon(Icons.add),
      ),
      //////////////////////////////////////////////////////////  3  ////////////////////////////////////////////

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
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

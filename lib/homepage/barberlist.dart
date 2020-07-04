//import 'dart:async';
import 'package:barber/msg/getdatafrom.dart';
import 'package:barber/msg/toasting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Barber extends StatefulWidget {
  @override
  _Barberlist createState() => _Barberlist();
}

class _Barberlist extends State<Barber> {
  int _selectedIndex = 0;
  String username;
  DocumentSnapshot _snapsho;
  String _timeplace;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    Getdatafrom().reservetime().then((value) => _timeplace = value);
    super.initState();
  }

  //_________________________________build_________________________________//
  @override
  Widget build(BuildContext context) {
    final String idofbarber = ModalRoute.of(context).settings.arguments;
    Getdatafrom().snapshotin(idofbarber).then((value) => _snapsho = value);
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
      StreamBuilder<QuerySnapshot>(
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapsho) {
          if (snapsho.hasError) return new Text('Error: ${snapsho.error}');
          switch (snapsho.connectionState) {
            case ConnectionState.waiting:
              return new Center(
                child: SpinKitRotatingCircle(
                  color: Colors.red[900],
                  size: 100.0,
                ),
              );
            default:
              return GoogleMap(
                mapType: MapType.normal,
                markers: Getdatafrom().createMarker(
                    _snapsho.data['posix'], _snapsho.data['posiy']),
                initialCameraPosition: CameraPosition(
                  target:
                      LatLng(_snapsho.data['posix'], _snapsho.data['posiy']),
                  zoom: 12.0,
                ),
              );
          }
        },
      ),
    ];
    return Scaffold(
      body: _children[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Getdatafrom().reservetime().then((value) => _timeplace = value);
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
            inst.setData({'time': _timeplace, 'name': snapshot.data['name']});
          } catch (e) {
            Toasting().showToast(e.toString());
          }
        },
        tooltip: 'add to list',
        child: Icon(Icons.add),
      ),
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

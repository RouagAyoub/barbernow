import 'package:barber/barberlist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Appforclient extends StatefulWidget
{
  @override
  _Clientapp createState() => _Clientapp();
}

class _Clientapp extends State<Appforclient>
{




  @override
  Widget build(BuildContext context) {
    return Scaffold
    (
      appBar: AppBar(title: Text('waiting list'),),
      body:StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('users').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError)
          return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting: return new Center(
            child: SpinKitRotatingCircle(
            color: Colors.red[900],
            size: 50.0,
            ),
          );
          default:
            return new ListView(
              children: snapshot.data.documents.map((DocumentSnapshot document) {
                return new ListTile(
                  title: new Text(document['email']),
                  subtitle: new Text(document['passw']),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Barber())),
                  
                );
              }).toList(),
            );
        }
      },
    )
    );
  }

}
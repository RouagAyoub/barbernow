import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Barber extends StatefulWidget
{
  @override
  _Barberlist createState() => _Barberlist();
}

class _Barberlist extends State<Barber>
{

  @override
  Widget build(BuildContext context) {
    return Scaffold
    (
      appBar: AppBar(title: Text('list client'),),
      body:StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('listwaiting').snapshots(),
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
                  title: new Text(document['name']),
                  subtitle: new Text(document['time']),
                  onTap: () => ,
                  
                );
              }).toList(),
            );
        }
      },
    )
    );
  }

}
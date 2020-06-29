import 'package:barber/barberlist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Appforclient extends StatefulWidget {
  @override
  _Clientapp createState() => _Clientapp();
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

class _Clientapp extends State<Appforclient> {
  Card buildItem(DocumentSnapshot doc) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: new Container(
          padding: const EdgeInsets.all(2.0),
          color: Color(0xFFcce3de),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(children: [
                    Row(children: [
                      Icon(Icons.person_outline, color: Colors.brown[500]),
                      Text(
                        doc.data['name'],
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ]),
                    Row(children: [
                      Icon(Icons.person_pin_circle, color: Colors.brown[900]),
                      Flexible(
                        child: Text(
                          doc.data['place'],
                          style:
                              TextStyle(fontSize: 16, color: Colors.blue[900]),
                        ),
                      ),
                    ]),
                  ]),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios),
                // shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(35.0)),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Barber(),
                      settings: RouteSettings(
                        arguments: doc.documentID,
                      ),
                    )),
                //child: Text('>', style: TextStyle(color: Colors.white)),
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Barber list'),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('barbers').snapshots(),
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
                    children: snapshot.data.documents
                        .map((doc) => buildItem(doc))
                        .toList());

              ///////////////////////////////////   2  ////////////////////////////////
            }
          },
        ));
  }

///////////////////////////////////////    4      //////////////////////////////////

}

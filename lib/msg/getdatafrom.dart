import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';

class Getdatafrom {
  Future<String> reservetime() async {
    Response response =
        await get('http://worldtimeapi.org/api/timezone/Africa/Algiers');
    Map data = jsonDecode(response.body);
    String offset = data['utc_offset'].substring(1, 3);
    DateTime now = DateTime.parse(data['datetime']);
    now = now.add(Duration(hours: int.parse(offset)));
    return now.toString();
  }

  Set<Marker> createMarker(double posisionlat, double posotionlon) {
    return <Marker>[
      Marker(
          markerId: MarkerId('home'),
          position: LatLng(posisionlat, posotionlon),
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: 'Current Location'))
    ].toSet();
  }

  Future<DocumentSnapshot> snapshotin(idofbarber) async {
    DocumentSnapshot _snapshotss = await Firestore.instance
        .collection('barbers')
        .document(idofbarber)
        .get();
    return _snapshotss;
  }
}

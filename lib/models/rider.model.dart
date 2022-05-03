import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RiderModel {
  String? id;
  String? name;
  LatLng? location;

  RiderModel({
    @required this.id,
    this.name,
    this.location,
  });

  factory RiderModel.fromMap(Map<String, dynamic> map) {
    try {
      double lat = 0;
      double lng = 0;

      if (map['location'] != null) {
        lat = map['location']['lat'] ?? 0;
        lng = map['location']['lng'];
      }

      return RiderModel(
        id: map['_id'],
        name: map['name'],
        location: LatLng(lat, lng),
      );
    } catch (e) {
      throw e;
    }
  }
}

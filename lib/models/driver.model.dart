import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverModel {
  String? id;
  String? name;
  LatLng? location;
  bool? isOnline;
  String? car;

  DriverModel({
    @required this.id,
    this.name,
    this.location,
    this.isOnline,
    this.car,
  });

  factory DriverModel.fromMap(Map<String, dynamic> map) {
    try {
      double lat = 0;
      double lng = 0;

      if (map['location'] != null) {
        lat = map['location']['lat'] ?? 0;
        lng = map['location']['lng'];
      }

      return DriverModel(
        id: map['_id'],
        name: map['name'],
        location: LatLng(lat, lng),
        isOnline: map['isOnline'],
        car: map['car'],
      );
    } catch (e) {
      throw e;
    }
  }
}

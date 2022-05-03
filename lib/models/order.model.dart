import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:sdride_driver/utils/functions.dart';

class OrderModel {
  String? id;
  LatLng? origin;
  LatLng? destination;
  Map<String, dynamic>? destinationDetails;
  String? riderId;
  String? driverId;
  bool? isPending;
  bool? isAccepted;
  bool? hasStarted;
  bool? hasCompleted;

  OrderModel({
    @required this.id,
    @required this.origin,
    @required this.destination,
    @required this.destinationDetails,
    @required this.riderId,
    this.driverId,
    @required this.isPending,
    @required this.isAccepted,
    @required this.hasStarted,
    @required this.hasCompleted,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    try {
      dynamic originLat = map['origin']['lat'];
      dynamic originLng = map['origin']['lng'];

      dynamic destinationLat = map['destination']['lat'];
      dynamic destinationLng = map['destination']['lng'];

      Map<String, dynamic> destinationDetails = {
        'name': map['destination']['name'],
        'address': map['destination']['address']
      };

      return OrderModel(
        id: map['_id'],
        origin: LatLng(originLat, originLng),
        destination: LatLng(destinationLat, destinationLng),
        destinationDetails: destinationDetails,
        riderId: map['riderId'],
        driverId: map['driverId'] ?? '',
        isPending: map['isPending'],
        isAccepted: map['isAccepted'],
        hasStarted: map['hasStarted'],
        hasCompleted: map['hasCompleted'],
      );
    } catch (e) {
      throw e;
    }
  }
}

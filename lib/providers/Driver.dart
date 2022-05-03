import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sdride_driver/models/driver.model.dart';
import 'package:sdride_driver/utils/request.dart';

class Driver extends ChangeNotifier {
  DriverModel? driver;

  Future createDriver() async {
    try {
      dynamic response = await new Request().post('/api/drivers/create');
      driver = DriverModel.fromMap(response['data']);

      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future updateLocation(LatLng location) async {
    try {
      await new Request().post('/api/drivers/update/location', body: {
        'lat': location.latitude,
        'lng': location.longitude,
        'id': driver!.id
      });

      driver!.location = location;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future updateOnline() async {
    try {
      bool isOnline = driver!.isOnline == true ? false : true;
      await new Request().post('/api/drivers/update/online', body: {
        'id': driver!.id,
        'isOnline': isOnline,
      });

      driver!.isOnline = isOnline;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }
}

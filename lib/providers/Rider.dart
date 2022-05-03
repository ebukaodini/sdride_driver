import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sdride_driver/models/rider.model.dart';
import 'package:sdride_driver/utils/request.dart';

class Rider extends ChangeNotifier {
  RiderModel? rider;

  Future createRider() async {
    try {
      dynamic response = await new Request().post('/api/riders/create');
      rider = RiderModel.fromMap(response['data']);

      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future updateLocation(LatLng location) async {
    try {
      await new Request().post('/api/riders/update/location', body: {
        'lat': location.latitude,
        'lng': location.longitude,
        'id': rider!.id
      });

      rider = RiderModel(id: rider!.id, name: rider!.name, location: location);
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future getLocation(String riderId) async {
    try {
      dynamic response =
          await new Request().get('/api/riders/$riderId/location');
      dynamic location = response['data']['location'];
      return LatLng(location['lat'], location['lng']);
    } catch (e) {
      throw e;
    }
  }
}

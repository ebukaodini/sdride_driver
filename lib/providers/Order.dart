import 'package:flutter/foundation.dart';
import 'package:sdride_driver/models/order.model.dart';
import 'package:sdride_driver/utils/request.dart';
import 'package:sdride_driver/widgets/notice.dart';

class Order extends ChangeNotifier {
  List<OrderModel>? orders = [];

  Future getOrders() async {
    try {
      dynamic response = await new Request().get('/api/orders/pending');

      List<dynamic> respOrders = response['data'].toList();
      orders?.clear();
      respOrders.forEach((order) {
        orders?.add(OrderModel.fromMap(order));
      });

      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future acceptOrder(String driverId, String orderId) async {
    try {
      await new Request().post('/api/orders/accept',
          body: {'id': orderId, 'driverId': driverId});
    } catch (e) {
      throw e;
    }
  }
}

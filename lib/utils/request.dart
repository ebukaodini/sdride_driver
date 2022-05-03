import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Request {
  final Dio _http = Dio();
  final String? _baseUrl = dotenv.env['BASEURL'];

  Future<dynamic> post(String uri, {dynamic body}) async {
    try {
      print(_baseUrl);
      print(uri);
      print(body);
      final response = await _http.post(
        "$_baseUrl$uri",
        data: body,
      );
      print(response.toString());

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw new Exception(response.data.message ?? response.statusMessage);
      }
    } catch (e) {
      print(uri);
      print(e.toString());
      throw e;
    }
  }

  Future<dynamic> get(String uri, {Map<String, dynamic>? query}) async {
    try {
      print(uri);
      final response = await _http.get(
        "$_baseUrl$uri",
        queryParameters: query,
      );
      print(response.toString());

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw new Exception(response.data.message ?? response.statusMessage);
      }
    } catch (e) {
      print(uri);
      print(e.toString());
      throw e;
    }
  }
}

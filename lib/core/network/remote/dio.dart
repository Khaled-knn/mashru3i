import 'package:dio/dio.dart';

class DioHelper {
  static late Dio dio;
  static void init() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://46.202.175.64:3000',
        receiveDataWhenStatusError: true,
      ),
    );
  }
  static Future<Response> getData({
    required String url,
    Map<String, dynamic>? query,
    String? token,
  }) async {
    dio.options.headers = {
      "Content-Type": "application/json",
      "Authorization": token ?? '',
    };
    return dio.get(url, queryParameters: query);
  }

  static Future<Response> postData({
    required String url,
    required Map<String, dynamic> data,
    String? token,
  }) async {
    dio.options.headers = {
      "Content-Type": "application/json",
      "Authorization": token ?? '',
    };
    return dio.post(url, data: data);
  }


  static Future<Response> deleteData({
    required String url,
    Map<String, dynamic>? data,
    String? token,
  }) async {
    dio.options.headers = _setHeaders(token);
    return await dio.delete(
      url,
      data: data,
    );
  }
  static Future<Response> updateData({
    required String url,
    Map<String, dynamic> ? data,
    String? token,
  }) async {
    dio.options.headers = _setHeaders(token);
    return await dio.put(
      url,
      data: data,
    );
  }
  static Map<String, dynamic> _setHeaders(String? token) {
    return {
      "Content-Type": "application/json",
      "Authorization": token ?? '',
    };
  }


  static Future<Response> postListData({
    required String url,
    required List<dynamic> data,
    String? token,
  }) async {
    dio.options.headers = {
      "Content-Type": "application/json",
      "Authorization": token ?? '',
    };
    return dio.post(url, data: data);
  }

}

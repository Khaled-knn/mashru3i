import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemsRepository {
  final Dio _dio;

  ItemsRepository({required Dio dio}) : _dio = dio;

  Future<void> deleteItem(int itemId) async {
    try {
      await _dio.delete(
        '/api/items/$itemId',
        options: Options(
          headers: {'Authorization': 'Bearer ${await _getToken()}'},
        ),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response?.statusCode == 403) {
      return 'لا يمكن حذف العنصر بعد مرور 24 ساعة';
    } else if (e.response?.statusCode == 404) {
      return 'العنصر غير موجود';
    }
    return 'فشل في حذف العنصر: ${e.message}';
  }

  Future<String> _getToken() async {
    // تطبيق طريقة الحصول على التوكن الخاصة بك
    final sharedPref = await SharedPreferences.getInstance();
    return sharedPref.getString('token') ?? '';
  }
}
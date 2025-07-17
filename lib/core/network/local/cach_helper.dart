import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences _sharedPreferences;

  // Initialization
  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  // Save data based on value type
  static Future<bool> saveData({
    required String key,
    required dynamic value,
  }) async {
    if (value is String) return await _sharedPreferences.setString(key, value);
    if (value is int) return await _sharedPreferences.setInt(key, value);
    if (value is bool) return await _sharedPreferences.setBool(key, value);
    if (value is double) return await _sharedPreferences.setDouble(key, value);

    // Type not supported
    throw Exception('Unsupported value type');
  }

  // Get data
  static dynamic getData({required String key}) {
    return _sharedPreferences.get(key);
  }

  // Remove specific key
  static Future<bool> removeData({required String key}) async {
    return await _sharedPreferences.remove(key);
  }

  // Clear all data (optional helper)
  static Future<bool> clearAll() async {
    return await _sharedPreferences.clear();
  }
}

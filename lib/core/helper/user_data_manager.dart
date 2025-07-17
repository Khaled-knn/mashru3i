import 'dart:convert';

import 'package:mashrou3i/data/models/user_model.dart';
import '../network/local/cach_helper.dart';

class UserDataManager {
  static const String _userTokenKey = 'userToken';
  static const String _userModelKey = 'userModel';

  static Future<void> saveUserData({
    required String token,
    required UserModel user,
  }) async {
    await CacheHelper.saveData(key: _userTokenKey, value: token);
    await CacheHelper.saveData(
        key: _userModelKey, value: jsonEncode(user.toJson()));
  }

  static String? getUserToken() {
    return CacheHelper.getData(key: _userTokenKey);
  }

  static UserModel? getUserModel() {
    final String? jsonString = CacheHelper.getData(key: _userModelKey);
    if (jsonString != null) {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return UserModel.fromJson(json);
    }
    return null;
  }

  static Future<void> clearUserData() async {
    await CacheHelper.removeData(key: _userTokenKey);
    await CacheHelper.removeData(key: _userModelKey);
  }
}

import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class FcmService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<String?> getFcmToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token == null) {
        print("⚠️ FCM token is null, waiting for onTokenRefresh");
      } else {
        print("✅ FCM Token (from getFcmToken): $token");
      }
      return token;
    } catch (e) {
      print("❌ Error getting FCM token: $e");
      return null;
    }
  }



  Future<void> sendFcmTokenToBackend({
    required int userId,
    required String userType, // 'user' أو 'creator'
    required String fcmToken,
  }) async {

    final String apiUrl = 'http://46.202.175.64:3000/api/update-fcm-token';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': userId,
          'type': userType,
          'fcmToken': fcmToken,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ FCM Token sent to backend successfully!');
      } else {
        print('❌ Failed to send FCM Token to backend. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('❌ Error sending FCM Token to backend: $e');
    }
  }

  void listenToTokenChanges(int userId, String userType) {
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print("🔔 New FCM Token refreshed: $newToken");
      sendFcmTokenToBackend(userId: userId, userType: userType, fcmToken: newToken);
    });
  }


  Future<void> requestNotificationPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }
}
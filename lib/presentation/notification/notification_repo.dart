import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mashrou3i/core/network/remote/dio.dart';

class NotificationRepo {
  static Future<Response> getUserNotifications({required String token}) async {
    try {
      final response = await DioHelper.getData(
        url: '/api/user-notifications'
        ,token: token,
      );
      debugPrint('User Notifications Response: ${response.data}');
      return response;
    } on DioException catch (e) {
      debugPrint('Error getting user notifications: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }

  static Future<Response> getCreatorNotifications({required String token}) async {
    try {
      final response = await DioHelper.getData(
        url: '/api/creator-notifications',
        token: token
      );
      debugPrint('Creator Notifications Response: ${response.data}');
      return response;
    } on DioException catch (e) {
      debugPrint('Error getting creator notifications: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }

  static Future<Response> markNotificationAsRead({
    required String token,
    required int notificationId,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await DioHelper.updateData(
        url: '/api/notifications/$notificationId/read',
        token: token,
        data: data,
      );
      debugPrint('Mark Notification As Read Response: ${response.data}');
      return response;
    } on DioException catch (e) {
      debugPrint('Error marking notification as read: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }

  static Future<Response> deleteNotification({
    required String token,
    required int notificationId,
  }) async {
    try {
      final response = await DioHelper.deleteData(
        url: '/api/notifications/$notificationId',
        token: token,
      );
      debugPrint('Delete Notification Response: ${response.data}');
      return response;
    } on DioException catch (e) {
      debugPrint('Error deleting notification: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }
}
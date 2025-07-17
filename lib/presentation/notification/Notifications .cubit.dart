import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/local/cach_helper.dart';
import '../../data/models/NotificationItem.dart';
import 'Notifications .states.dart';
import 'notification_repo.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit() : super(NotificationsInitial());

  String? _getToken(String userType) {
    if (userType == 'user') {
      return CacheHelper.getData(key: 'userToken');
    } else if (userType == 'creator') {
      return CacheHelper.getData(key: 'token');
    }
    return null;
  }

  Future<void> fetchNotifications({required String userType}) async {
    emit(NotificationsLoading());
    try {
      final token = _getToken(userType);
      if (token == null || token.isEmpty) {
        emit(NotificationsError('You are not logged in. Please log in again.'.tr()));
        return;
      }

      final response;
      if (userType == 'user') {
        response = await NotificationRepo.getUserNotifications(token: 'Bearer $token');
      } else if (userType == 'creator') {
        response = await NotificationRepo.getCreatorNotifications(token: 'Bearer $token');
      } else {
        emit(NotificationsError('Invalid user type specified.'.tr()));
        return;
      }
      debugPrint('>>> Raw Notifications API Response: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['notifications'];
        final notifications = data.map((item) => NotificationItem.fromJson(item)).toList();
        emit(NotificationsLoaded(notifications: notifications));
      } else {

        emit(NotificationsError(response.data['message'] ?? 'Failed to fetch notifications. Status: ${response.statusCode}'.tr()));
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      emit(NotificationsError('Failed to load notifications: ${e.toString()}'.tr()));
    }
  }


  Future<void> markNotificationAsRead(int notificationId,userType ) async {
    final currentState = state;
    if (currentState is NotificationsLoaded) {

      final originalNotification = currentState.notifications.firstWhere(
            (n) => n.id == notificationId,
      );

      final updatedNotificationData = NotificationItem(
        id: originalNotification.id,
        userId: originalNotification.userId,
        creatorId: originalNotification.creatorId,
        orderId: originalNotification.orderId,
        title: originalNotification.title,
        body: originalNotification.body,
        isRead: true,
        createdAt: originalNotification.createdAt,
        data: originalNotification.data,
        icon: originalNotification.icon,
        color: originalNotification.color,
      );


      final updatedNotificationsList = currentState.notifications.map((n) {
        if (n.id == notificationId) {
          return updatedNotificationData;
        }
        return n;
      }).toList();
      emit(NotificationsLoaded(notifications: updatedNotificationsList));

      try {
        final token = _getToken(userType);
        if (token == null || token.isEmpty) {
          throw Exception('Authentication token not found.');
        }

        await NotificationRepo.markNotificationAsRead(
          token: 'Bearer $token',
          notificationId: notificationId,
          data: updatedNotificationData.toJson(),
        );

      } catch (e) {
        emit(NotificationsLoaded(notifications: currentState.notifications));
        emit(NotificationsError('Failed to mark notification as read: ${e.toString()}'.tr()));
      }
    }
  }


  Future<void> markAllNotificationsAsRead(String userType) async {
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      final unreadNotifications = currentState.notifications.where((n) => !n.isRead).toList();
      if (unreadNotifications.isEmpty) return;

      // Optimistic update for all unread notifications
      final updatedNotifications = currentState.notifications.map((n) => NotificationItem(
        id: n.id,
        userId: n.userId,
        creatorId: n.creatorId,
        orderId: n.orderId,
        title: n.title,
        body: n.body,
        isRead: true,
        createdAt: n.createdAt,
        data: n.data,
        icon: n.icon,
        color: n.color,
      )).toList();
      emit(NotificationsLoaded(notifications: updatedNotifications));

      try {
        final token = _getToken(userType);
        if (token == null || token.isEmpty) {
          throw Exception('Authentication token not found.');
        }

        for (var notification in unreadNotifications) {
          await NotificationRepo.markNotificationAsRead(token: 'Bearer $token', notificationId: notification.id);
        }
      } catch (e) {
        debugPrint('Error marking all notifications as read: $e');
        // Rollback on failure
        emit(NotificationsLoaded(notifications: currentState.notifications));
        emit(NotificationsError('Failed to mark all notifications as read: ${e.toString()}'.tr()));
      }
    }
  }


  Future<void> deleteNotification(int notificationId ,userType) async {
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      final originalNotifications = List<NotificationItem>.from(currentState.notifications);
      final updatedNotifications = currentState.notifications.where((n) => n.id != notificationId).toList();
      emit(NotificationsLoaded(notifications: updatedNotifications));

      try {
        final token = _getToken(userType);
        if (token == null || token.isEmpty) {
          throw Exception('Authentication token not found.');
        }
        await NotificationRepo.deleteNotification(token: 'Bearer $token', notificationId: notificationId);
      } catch (e) {
        debugPrint('Error deleting notification via API: $e');

        emit(NotificationsLoaded(notifications: originalNotifications));
        emit(NotificationsError('Failed to delete notification: ${e.toString()}'.tr()));
      }
    }
  }
}
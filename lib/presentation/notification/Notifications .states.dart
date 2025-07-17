// lib/presentation/screens/notifications_screen/notifications_states.dart

import '../../data/models/NotificationItem.dart';

abstract class NotificationsState {}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationItem> notifications;

  NotificationsLoaded({required this.notifications});
}

class NotificationsError extends NotificationsState {
  final String message;

  NotificationsError(this.message);
}
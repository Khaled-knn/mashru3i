// lib/ui/screens/notifications/NotificationsScreen.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../../../../../core/theme/color.dart';
import '../../../../../../data/models/NotificationItem.dart';
import '../../../../../notification/Notifications .cubit.dart';
import '../../../../../notification/Notifications .states.dart';
import '../../../../../widgets/compnents.dart';


class NotificationsScreen extends StatefulWidget {
  final String userType;
  const NotificationsScreen({super.key, required this.userType});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();

    context.read<NotificationsCubit>().fetchNotifications(userType: widget.userType);


    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('App resumed, fetching notifications...');
      context.read<NotificationsCubit>().fetchNotifications(userType: widget.userType);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Notifications'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: popButton(context),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
              child: IconButton(
                icon: Icon(Icons.notifications_on, color: textColor),
                onPressed: (){
                },
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<NotificationsCubit, NotificationsState>(
        listener: (context, state) {
          if (state is NotificationsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          } else if (state is NotificationsLoaded) {
            debugPrint('Notifications Loaded: ${state.notifications.length}');
          }
        },
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationsError) {
            return Center(child: Text(state.message));
          } else if (state is NotificationsLoaded) {
            final unreadNotificationsCount = state.notifications.where((n) => !n.isRead).length;
            return Column(
              children: [
                _buildHeader(context, unreadNotificationsCount > 0, state.notifications),
                Expanded(
                  child: state.notifications.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications found'.tr(),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                      : RefreshIndicator(
                    onRefresh: () async {
                      await context.read<NotificationsCubit>().fetchNotifications(userType: widget.userType);
                    },
                    child: ListView.builder(
                      itemCount: state.notifications.length,
                      itemBuilder: (context, index) {
                        final notification = state.notifications[index];
                        return Dismissible(
                          key: ValueKey(notification.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Colors.red,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return AlertDialog(
                                  title: const Text("Confirm Delete").tr(),
                                  content: const Text("Are you sure you want to delete this notification?").tr(),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.of(dialogContext).pop(false),
                                      child:  Text("Cancel" , style: TextStyle(color: textColor),),
                                    ),
                                    TextButton(
                                        onPressed: () => Navigator.of(dialogContext).pop(true),
                                        child:  Text("Delete", style: TextStyle(color:  Colors.red),)
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          onDismissed: (direction) {
                            context.read<NotificationsCubit>().deleteNotification(notification.id,'user'); // 💡 تأكد من تمرير userType هنا
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Notification deleted.'.tr() , style: TextStyle(color: Colors.black),) ,
                                  backgroundColor: Theme.of(context).primaryColor,
                              ),
                            );
                          },
                          child: _buildNotificationCard(context, notification),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool hasUnread, List<NotificationItem> allNotifications) {
    final newNotificationsCount = allNotifications.where((n) => !n.isRead).length;

    return Padding(
      padding: const EdgeInsets.only(top: 25.0, left: 16.0, right: 16.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'New Notifications (${newNotificationsCount})'.tr(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.grey[800],
            ),
          ),
          if (hasUnread)
            TextButton(
              onPressed: () {
                context.read<NotificationsCubit>().markAllNotificationsAsRead(widget.userType);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('All notifications marked as read.'.tr(), style: TextStyle(color:Colors.black),) , backgroundColor: Theme.of(context).primaryColor,),
                );
              },
              child: Text(
                'Mark all as read'.tr(),
                style: TextStyle(color:textColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationItem notification) {
    return GestureDetector(
      onTap: () {
        if (!notification.isRead) {
          context.read<NotificationsCubit>().markNotificationAsRead(notification.id, widget.userType); // 💡 تأكد من تمرير userType هنا
        }
        if (notification.orderId != null) {
          debugPrint('Notification tapped for order ID: ${notification.orderId} with type: ${notification.data?['type']}');
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            decoration: BoxDecoration(
              border: !notification.isRead
                  ? Border(
                left: BorderSide(
                  color: notification.color,
                  width: 4,
                ),
              )
                  : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: notification.color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      notification.icon,
                      color: notification.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontWeight: !notification.isRead
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              _formatTime(notification.createdAt),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.body,
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'just now'.tr();
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${'m ago'.tr()}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${'h ago'.tr()}';
    } else if (difference.inDays == 1) {
      return 'Yesterday'.tr();
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${'d ago'.tr()}';
    } else {
      return DateFormat('MMM d, y').format(time);
    }
  }
}
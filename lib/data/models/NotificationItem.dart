// lib/data/models/NotificationItem.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mashrou3i/core/theme/color.dart';

class NotificationItem {
  final int id;
  final int? userId;
  final int? creatorId;
  final int? orderId;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  final IconData icon;
  final Color color;

  NotificationItem({
    required this.id,
    this.userId,
    this.creatorId,
    this.orderId,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.data,
    this.icon = Icons.notifications,
    this.color = Colors.blue,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? parsedData;
    if (json['data'] != null) {
      if (json['data'] is String) {
        try {
          parsedData = jsonDecode(json['data'] as String);
        } catch (e) {
          debugPrint('Error parsing notification data JSON string: $e');
          parsedData = {'rawData': json['data']};
        }
      } else if (json['data'] is Map) {
        parsedData = json['data'] as Map<String, dynamic>;
      } else {
        debugPrint('Warning: json[\'data\'] is neither String nor Map: ${json['data'].runtimeType}');
      }
    }

    IconData determinedIcon = Icons.notifications;
    Color determinedColor = Colors.blue;
    String notificationType = parsedData?['type'] ?? '';

    switch (notificationType) {
      case 'new_order':
        determinedIcon = Icons.shopping_bag;
        determinedColor = Color.fromRGBO(119, 247, 211, 1);
        break;
      case 'order_accepted':
        determinedIcon = Icons.check_circle;
        determinedColor = Colors.teal;
        break;
      case 'order_paid':
        determinedIcon = Icons.payment;
        determinedColor = textColor;
        break;
      case 'order_canceled':
        determinedIcon = Icons.cancel;
        determinedColor = Colors.red;
        break;
      case 'coins_added':
        determinedIcon = Icons.attach_money;
        determinedColor = Colors.amber;
        break;
      default:
        determinedIcon = Icons.notifications;
        determinedColor = Colors.grey;
    }

    return NotificationItem(
      id: json['id'] as int,
      userId: json['userId'] as int?,
      creatorId: json['creatorId'] as int?,
      orderId: json['orderId'] as int?,
      title: json['title'] as String,
      body: json['body'] as String,
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      data: parsedData,
      icon: determinedIcon,
      color: determinedColor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'creatorId': creatorId,
      'orderId': orderId,
      'title': title,
      'body': body,
      'isRead': isRead ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'data': data != null ? jsonEncode(data) : null,
    };
  }
}
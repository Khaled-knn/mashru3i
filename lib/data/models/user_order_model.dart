// user_order_model.dart

import 'dart:convert';

class UserOrder {
  final int orderId;
  final int userId;
  final int creatorId;
  final double totalAmount;
  final String status;
  final String? paymentMethod;
  final String? shippingAddress;
  final String? notes;
  final String paymentStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<UserOrderItem> orderItems;
  final List<CreatorPaymentMethod> creatorPaymentMethods;

  UserOrder({
    required this.orderId,
    required this.userId,
    required this.creatorId,
    required this.totalAmount,
    required this.status,
    this.paymentMethod,
    this.shippingAddress,
    this.notes,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.orderItems,
    required this.creatorPaymentMethods,
  });

  factory UserOrder.fromJson(Map<String, dynamic> json) {
    return UserOrder(
      orderId: json['order_id'] as int,
      userId: json['user_id'] as int,
      creatorId: json['creator_id'] as int,
      totalAmount: double.parse(json['total_amount']?.toString() ?? '0.0'),      status: json['status'] as String? ?? 'pending',
      paymentMethod: json['payment_method'] as String?,
      shippingAddress: json['shipping_address'] as String?,
      notes: json['notes'] as String?,
      paymentStatus: json['payment_status'] as String? ?? 'unpaid',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      orderItems: (json['order_items'] as List<dynamic>?)
          ?.map((item) => UserOrderItem.fromJson(item))
          .toList() ??
          [],
      creatorPaymentMethods: (json['creator_payment_methods'] as List<dynamic>?)
          ?.map((method) => CreatorPaymentMethod.fromJson(method))
          .toList() ??
          [],
    );
  }
}

// 💡 كلاس جديد لعناصر الطلب (Order Items)
class UserOrderItem {
  final int itemId;
  final String? itemName;
  final int quantity;
  final double pricePerItem;
  final String? specialRequest;
  final List<Map<String, dynamic>>? extrasDetails;

  UserOrderItem({
    required this.itemId,
    this.itemName,
    required this.quantity,
    required this.pricePerItem,
    this.specialRequest,
    this.extrasDetails,
  });

  factory UserOrderItem.fromJson(Map<String, dynamic> json) {
    return UserOrderItem(
      itemId: json['item_id'] as int,
      itemName: json['item_name'] as String? ?? 'Unknown Item',
      quantity: json['quantity'] as int? ?? 1,
      pricePerItem: (json['price_per_item'] as num?)?.toDouble() ?? 0.0,
      specialRequest: json['special_request'] as String?,

      extrasDetails: (json['extras_details'] is String)
          ? (json['extras_details'] != null && (json['extras_details'] as String).isNotEmpty
          ? (jsonDecode(json['extras_details']) as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList()
          : null)
          : (json['extras_details'] is List)
          ? (json['extras_details'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList()
          : null,
    );
  }
}


class CreatorPaymentMethod {
  final String method;
  final String? accountInfo;

  CreatorPaymentMethod({
    required this.method,
    this.accountInfo,
  });

  factory CreatorPaymentMethod.fromJson(Map<String, dynamic> json) {
    return CreatorPaymentMethod(
      method: json['method'] as String,
      accountInfo: json['account_info'] as String?,
    );
  }
}


class UserOrderResponse {
  final bool success;
  final List<UserOrder> orders;

  UserOrderResponse({
    required this.success,
    required this.orders,
  });

  factory UserOrderResponse.fromJson(Map<String, dynamic> json) {
    return UserOrderResponse(
      success: json['success'] as bool? ?? true,
      orders: (json['orders'] as List<dynamic>?)
          ?.map((order) => UserOrder.fromJson(order))
          .toList() ??
          [],
    );
  }
}
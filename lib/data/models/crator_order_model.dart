// creator_order_model.dart

import 'dart:convert';

class CreatorOrder {
  final int orderId;
  final int userId;
  final String? userFirstName;
  final String? userPhoneNumber;
  final double totalAmount;
  final String status;
  final String? paymentMethod;
  final String? shippingAddress;
  final String? notes;
  final String paymentStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CreatorOrderItem> orderItems;

  CreatorOrder({
    required this.orderId,
    required this.userId,
    this.userFirstName,
    this.userPhoneNumber,
    required this.totalAmount,
    required this.status,
    this.paymentMethod,
    this.shippingAddress,
    this.notes,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.orderItems,
  });

  factory CreatorOrder.fromJson(Map<String, dynamic> json) {
    return CreatorOrder(
      orderId: json['order_id'] as int,
      userId: json['user_id'] as int,
      userFirstName: json['user_first_name'] as String?,
      userPhoneNumber: json['user_phone_number'] as String?,
      totalAmount: double.parse(json['total_amount']?.toString() ?? '0'),
      status: json['status'] as String? ?? 'pending',
      paymentMethod: json['payment_method'] as String?,
      shippingAddress: json['shipping_address'] as String?,
      notes: json['notes'] as String?,
      paymentStatus: json['payment_status'] as String? ?? 'unpaid',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      orderItems: (json['order_items'] as List<dynamic>?)
          ?.map((item) => CreatorOrderItem.fromJson(item))
          .toList() ??
          [],
    );
  }
}

class CreatorOrderItem {
  final int itemId;
  final String? itemName;
  final int quantity;
  final double pricePerItem;
  final String? specialRequest;
  final List<Map<String, dynamic>>? extrasDetails;

  CreatorOrderItem({
    required this.itemId,
    this.itemName,
    required this.quantity,
    required this.pricePerItem,
    this.specialRequest,
    this.extrasDetails,
  });

  factory CreatorOrderItem.fromJson(Map<String, dynamic> json) {
    return CreatorOrderItem(
      itemId: json['item_id'] as int,
      itemName: json['item_name'] as String? ?? 'Unknown Item',
      quantity: json['quantity'] as int? ?? 1,
      pricePerItem: (json['price_per_item'] as num?)?.toDouble() ?? 0.0,
      specialRequest: json['special_request'] as String?, // 💡 إضافة
      // 💡 إضافة: تحليل extras_details إذا كانت موجودة
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

class CreatorOrderResponse {
  final bool success;
  final List<CreatorOrder> orders;
  final double monthlyIncome; // 💡 إضافة: الدخل الشهري

  CreatorOrderResponse({
    required this.success,
    required this.orders,
    required this.monthlyIncome, // 💡 إضافة
  });

  factory CreatorOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreatorOrderResponse(
      success: json['success'] as bool? ?? false,
      orders: (json['orders'] as List<dynamic>?)
          ?.map((order) => CreatorOrder.fromJson(order))
          .toList() ??
          [],
      monthlyIncome: (json['monthly_income'] as num?)?.toDouble() ?? 0.0, // 💡 إضافة
    );
  }
}
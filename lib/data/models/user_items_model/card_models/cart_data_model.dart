import 'package:equatable/equatable.dart';
import '../cart_model.dart';
import 'creator_payment_method_model.dart'; // ✅ تأكد من المسار الصحيح

class CartDataModel extends Equatable {
  final List<CartItem> items; // ✅ استخدم CartItem بدل CartItemModel
  final String subtotal;
  final String deliveryFee;
  final String discountAmount;
  final String? discountMessage;
  final String total;
  final List<CreatorPaymentMethodModel> creatorPaymentMethods;

  const CartDataModel({
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.discountAmount,
    this.discountMessage,
    required this.total,
    required this.creatorPaymentMethods,
  });

  factory CartDataModel.fromJson(Map<String, dynamic> json) {
    return CartDataModel(
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => CartItem.fromJson(e as Map<String, dynamic>)) // ✅ استخدم CartItem
          .toList() ??
          [],
      subtotal: json['subtotal'] as String,
      deliveryFee: json['delivery_fee'] as String,
      discountAmount: json['discount_amount'] as String,
      discountMessage: json['discount_message'] as String?,
      total: json['total'] as String,
      creatorPaymentMethods: (json['creator_payment_methods'] as List<dynamic>?)
          ?.map((e) => CreatorPaymentMethodModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'discount_amount': discountAmount,
      'discount_message': discountMessage,
      'total': total,
      'creator_payment_methods': creatorPaymentMethods.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    items,
    subtotal,
    deliveryFee,
    discountAmount,
    discountMessage,
    total,
    creatorPaymentMethods,
  ];
}
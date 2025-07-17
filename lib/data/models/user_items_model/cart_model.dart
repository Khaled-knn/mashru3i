import 'dart:convert'; // ممكن ما نحتاجه إذا ما في أي jsonDecode تاني
import 'package:equatable/equatable.dart';

import 'card_models/ExtraItem_model.dart'; // تأكد من المسار الصحيح

class CartItem extends Equatable {
  final int cartId;
  final int productId;
  final int quantity;
  final String? specialRequest;
  final List<ExtraItem> extras;
  final String name;
  final double price;
  final List<String> pictures;
  final int creatorId;
  final double baseTotal;
  final double extrasTotalPerItem;
  final double itemTotal;

  const CartItem({
    required this.cartId,
    required this.productId,
    required this.quantity,
    this.specialRequest,
    required this.extras,
    required this.name,
    required this.price,
    required this.pictures,
    required this.creatorId,
    required this.baseTotal,
    required this.extrasTotalPerItem,
    required this.itemTotal,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      cartId: json['cart_id'] as int,
      productId: json['product_id'] as int,
      quantity: json['quantity'] as int,
      specialRequest: json['special_request'] as String?,

      // ✅ التعديل هنا: بما أن الـ Backend يرسل 'extras' كـ List<Map<String, dynamic>>
      extras: (json['extras'] as List<dynamic>?)
          ?.map((extra) => ExtraItem.fromJson(extra as Map<String, dynamic>))
          .toList() ?? [],

      name: json['name'] as String,
      price: double.parse(json['price'].toString()),
      pictures: (json['pictures'] is String && json['pictures'].isNotEmpty)
          ? List<String>.from(jsonDecode(json['pictures']))
          : (json['pictures'] is List)
          ? List<String>.from(json['pictures'])
          : [],
      creatorId: json['creator_id'] as int,
      baseTotal: double.parse(json['base_total'].toString()),
      extrasTotalPerItem: double.parse(json['extras_total_per_item'].toString()),
      itemTotal: double.parse(json['item_total'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cart_id': cartId,
      'product_id': productId,
      'quantity': quantity,
      'special_request': specialRequest,
      'extras': extras.map((e) => e.toJson()).toList(),
      'name': name,
      'price': price,
      'pictures': pictures,
      'creator_id': creatorId,
      'base_total': baseTotal,
      'extras_total_per_item': extrasTotalPerItem,
      'item_total': itemTotal,
    };
  }

  @override
  List<Object?> get props => [
    cartId,
    productId,
    quantity,
    specialRequest,
    extras,
    name,
    price,
    pictures,
    creatorId,
    baseTotal,
    extrasTotalPerItem,
    itemTotal,
  ];
}
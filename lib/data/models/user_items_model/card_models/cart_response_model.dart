import 'dart:convert';
import 'package:equatable/equatable.dart';

import 'cart_data_model.dart'; // ✅ تأكد من المسار الصحيح

class CartResponseModel extends Equatable {
  final bool success;
  final CartDataModel? data;
  final String? message;
  final String? error; // لإظهار رسائل الخطأ من الـ backend

  const CartResponseModel({
    required this.success,
    this.data,
    this.message,
    this.error,
  });

  factory CartResponseModel.fromJson(Map<String, dynamic> json) {
    return CartResponseModel(
      success: json['success'] as bool,
      data: json['data'] != null ? CartDataModel.fromJson(json['data'] as Map<String, dynamic>) : null,
      message: json['message'] as String?,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
      'message': message,
      'error': error,
    };
  }

  @override
  List<Object?> get props => [success, data, message, error];
}
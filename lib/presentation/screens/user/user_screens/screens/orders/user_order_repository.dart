// lib/data/repository/user_order_repository.dart

import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../../../../core/network/remote/dio.dart';
import '../../../../../../data/models/user_order_model.dart';

class UserOrderRepository {
  final Dio _dio = DioHelper.dio;

  Future<UserOrderResponse> getUserOrders(String token) async {
    try {
      final response = await _dio.get(
        'http://46.202.175.64:3000/api/orders/user-orders',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return UserOrderResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('DioError fetching user orders: ${e.message}');
      throw Exception('Failed to fetch user orders: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      print('Error fetching user orders: ${e.toString()}');
      throw Exception('Failed to fetch user orders: ${e.toString()}');
    }
  }

  Future<void> confirmPayment({
    required String token,
    required int orderId,
    required String paymentMethod,
  }) async {
    try {
      final response = await _dio.put(
        'http://46.202.175.64:3000/api/orders/$orderId/confirm-payment',
        data: {
          'payment_method': paymentMethod,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to confirm payment: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      print('DioError confirming payment: ${e.message}');
      throw Exception('Failed to confirm payment: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      print('Error confirming payment: ${e.toString()}');
      throw Exception('Failed to confirm payment: ${e.toString()}');
    }
  }
}
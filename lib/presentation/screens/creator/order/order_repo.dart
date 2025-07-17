// creator_order_repository.dart
import 'dart:convert';
import '../../../../core/network/remote/dio.dart';
import '../../../../data/models/crator_order_model.dart';

class CreatorOrderRepository {
  Future<CreatorOrderResponse> getCreatorOrders(String token) async {
    try {
      final response = await DioHelper.getData(
        url: '/api/orders/creator',
        token: 'Bearer $token',
      );
      return CreatorOrderResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch creator orders: ${e.toString()}');
    }
  }

  Future<void> acceptOrCancelOrder({
    required String token,
    required int orderId,
    required String status,
    double? deliveryTimeValue,
    String? deliveryTimeUnit,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'status': status,
      };

      if (status == 'accepted') {
        if (deliveryTimeValue == null || deliveryTimeUnit == null) {
          throw Exception('Delivery time value and unit are required for accepted status.');
        }
        data['delivery_time_value'] = deliveryTimeValue;
        data['delivery_time_unit'] = deliveryTimeUnit;
      }

      await DioHelper.updateData(
        url: '/api/orders/$orderId/creator-action',
        data: data,
        token: 'Bearer $token',
      );
    } catch (e) {
      throw Exception('Failed to update order status: ${e.toString()}');
    }
  }

  Future<void> confirmPayment({
    required String token,
    required int orderId,
    required String paymentMethod,
  }) async {
    try {
      await DioHelper.updateData(
        url: '/api/orders/$orderId/confirm-payment',
        data: {
          'payment_method': paymentMethod,
        },
        token: 'Bearer $token',
      );
    } catch (e) {
      throw Exception('Failed to confirm payment: ${e.toString()}');
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';

import 'order_repo.dart';
import 'order_states.dart';

class CreatorOrderCubit extends Cubit<CreatorOrderState> {
  final CreatorOrderRepository _repository;

  CreatorOrderCubit(this._repository) : super(CreatorOrderInitial());

  Future<void> fetchCreatorOrders(String token) async {
    emit(CreatorOrderLoading());
    try {
      final response = await _repository.getCreatorOrders(token);
      emit(CreatorOrderLoaded(response.orders));
    } catch (e) {
      print('Error fetching creator orders: ${e.toString()}');
      emit(CreatorOrderError(e.toString()));
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
      emit(CreatorOrderUpdating(orderId));
      await _repository.acceptOrCancelOrder(
        token: token,
        orderId: orderId,
        status: status,
        deliveryTimeValue: deliveryTimeValue,
        deliveryTimeUnit: deliveryTimeUnit,
      );
      await fetchCreatorOrders(token);
    } catch (e) {
      print('Error updating order status: ${e.toString()}');
      emit(CreatorOrderError('Failed to update order: ${e.toString()}'));
      await fetchCreatorOrders(token);
    }
  }

  Future<void> confirmPayment({
    required String token,
    required int orderId,
    required String paymentMethod,
  }) async {
    try {
      emit(CreatorOrderUpdating(orderId));
      await _repository.confirmPayment(
        token: token,
        orderId: orderId,
        paymentMethod: paymentMethod,
      );
      await fetchCreatorOrders(token);
    } catch (e) {
      print('Error confirming payment: ${e.toString()}');
      emit(CreatorOrderError('Failed to confirm payment: ${e.toString()}'));
      await fetchCreatorOrders(token);
    }
  }
}


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mashrou3i/presentation/screens/user/user_screens/screens/orders/user_order_repository.dart';
import '../../../../../../core/network/local/cach_helper.dart';
import '../../../../../../data/models/user_order_model.dart';

import 'user_order_statrs.dart';

class UserOrdersCubit extends Cubit<UserOrdersState> {
  final UserOrderRepository _repository;

  UserOrdersCubit(this._repository) : super(UserOrdersInitial());

  Future<void> fetchUserOrders() async {
    emit(UserOrdersLoading());
    try {
      final token = CacheHelper.getData(key: 'userToken');
      if (token == null) {
        emit(UserOrdersError('Authentication token not found.'));
        return;
      }
      final response = await _repository.getUserOrders(token);
      emit(UserOrdersLoaded(response.orders));
    } catch (e) {
      print('Error fetching user orders: ${e.toString()}');
      emit(UserOrdersError('Failed to load orders: ${e.toString()}'));
    }
  }

  Future<void> confirmPayment({
    required int orderId,
    required String paymentMethod,
  }) async {
    emit(UserOrdersUpdating(orderId));
    try {
      final token = CacheHelper.getData(key: 'userToken');
      if (token == null) {
        emit(UserOrdersError('Authentication token not found.'));
        return;
      }
      await _repository.confirmPayment(
        token: token,
        orderId: orderId,
        paymentMethod: paymentMethod,
      );
      await fetchUserOrders();
    } catch (e) {
      print('Error confirming payment: ${e.toString()}');
      emit(UserOrdersError('Failed to confirm payment: ${e.toString()}'));
      await fetchUserOrders();
    }
  }
}
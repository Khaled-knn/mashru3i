// user_order_statrs.dart

import '../../../../../../data/models/user_order_model.dart';

abstract class UserOrdersState {}

class UserOrdersInitial extends UserOrdersState {}

class UserOrdersLoading extends UserOrdersState {}

class UserOrdersLoaded extends UserOrdersState {
  final List<UserOrder> orders;

  UserOrdersLoaded(this.orders);
}

class UserOrdersUpdating extends UserOrdersState {
  final int orderId;

  UserOrdersUpdating(this.orderId);
}

class UserOrdersError extends UserOrdersState {
  final String message;

  UserOrdersError(this.message);
}
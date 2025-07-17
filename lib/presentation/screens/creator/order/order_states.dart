// creator_order_state.dart
import '../../../../data/models/crator_order_model.dart';

sealed class CreatorOrderState {}

final class CreatorOrderInitial extends CreatorOrderState {}

final class CreatorOrderLoading extends CreatorOrderState {}

final class CreatorOrderLoaded extends CreatorOrderState {
  final List<CreatorOrder> orders;
  CreatorOrderLoaded(this.orders);
}

final class CreatorOrderUpdating extends CreatorOrderState {
  final int orderId;

  CreatorOrderUpdating(this.orderId);
}

final class CreatorOrderError extends CreatorOrderState {
  final String message;

  CreatorOrderError(this.message);
}
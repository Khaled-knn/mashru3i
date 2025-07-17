import 'package:equatable/equatable.dart';
import '../../../../../../../data/creatorsItems.dart';
import '../../../../../../../data/models/user_items_model/card_models/cart_data_model.dart';


abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}
class AddCartLoading extends CartState {}
class OrderPlacing extends CartState {}

class CartLoaded extends CartState {
  final CartDataModel cart;
  final CreatorItem? creatorInfo;

  const CartLoaded({required this.cart, this.creatorInfo});

  @override
  List<Object?> get props => [cart, creatorInfo];
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object> get props => [message];
}

class OrderPlacedSuccess extends CartState {
  final String message;

  const OrderPlacedSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class AddCartLoaded extends CartState {
  final String message;

  const AddCartLoaded({required this.message});

  @override
  List<Object> get props => [message];
}
class OrderPlacingError extends CartState {
  final String message;

  const OrderPlacingError({required this.message});

  @override
  List<Object> get props => [message];
}

class CartItemRemoved extends CartState {
  final String message;

  const CartItemRemoved({this.message = "Item removed from cart."});

  @override
  List<Object> get props => [message];
}


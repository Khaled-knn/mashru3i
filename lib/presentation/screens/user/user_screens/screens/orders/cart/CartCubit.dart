import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../core/network/local/cach_helper.dart';
import '../../../../../../../core/network/remote/dio.dart';
import '../../../../../../../data/models/user_items_model/card_models/cart_data_model.dart';
import '../../../../../../../data/models/user_items_model/card_models/cart_response_model.dart';
import '../../../../../../../data/models/user_items_model/cart_model.dart';
import '../../../../../../../data/creatorsItems.dart';




import 'CartState.dart';



class CartCubit extends Cubit<CartState> {
  final Dio dio;

  CartCubit({required this.dio}) : super(CartInitial());

  CartDataModel? currentCartData;


  Future<void> fetchCart() async {
    final userId = CacheHelper.getData(key: 'userIdTwo');
    final token = CacheHelper.getData(key: 'userToken');

    if (userId == null || token == null) {
      emit(CartError("User not authenticated or token not found. Please log in."));
      return;
    }

    emit(CartLoading());
    try {
      final response = await dio.get(
        "/api/cart/$userId",
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final cartResponse = CartResponseModel.fromJson(response.data);

      if (cartResponse.success && cartResponse.data != null) {
        currentCartData = cartResponse.data;


        emit(CartLoaded(
          cart: currentCartData!,
        ));
      } else {

        emit(CartError(cartResponse.message ?? cartResponse.error ?? 'Failed to load cart.'));
      }
    } on DioException catch (e) {
      print("Error fetching cart: ${e.response?.data ?? e.message}");
      emit(CartError(e.response?.data['message'] ?? e.response?.data['error'] ?? "Failed to load cart."));
    } catch (e) {
      print("Unexpected error fetching cart: $e");
      emit(CartError("An unexpected error occurred while fetching cart: ${e.toString()}"));
    }
  }


  Future<void> placeOrder({

    required String shippingAddress,
    required String userName,
    required String userPhone,
    String? notes,
  }) async {
    final token = CacheHelper.getData(key: 'userToken');
    if (token == null) {
      emit(CartError("User not authenticated. Please log in."));
      return;
    }

    if (currentCartData == null || currentCartData!.items.isEmpty) {
      emit(CartError("Cart is empty or not loaded."));
      return;
    }

    emit(OrderPlacing());

    try {

      final int? creatorId = currentCartData!.items.isNotEmpty ? currentCartData!.items[0].creatorId : null;
      if (creatorId == null) {
        emit(CartError("Creator ID not found for the order."));
        return;
      }

      final orderData = {
        "creator_id": creatorId,
        "shipping_address": shippingAddress,
        "user_name": userName,
        "user_phone": userPhone,
        "notes": notes ?? '',
        "subtotal": double.parse(currentCartData!.subtotal),
        "delivery_fee": double.parse(currentCartData!.deliveryFee),
        "discount_amount": double.parse(currentCartData!.discountAmount),
        "cart_items_details": currentCartData!.items.map((item) {
          List<Map<String, dynamic>> itemExtras = [];
          if (item.extras != null) {
            itemExtras = item.extras.map((e) {
              return {
                "name": e.name,
                "price": e.price ?? 0.0,
              };
            }).toList();
          }

          return {
            "product_id": item.productId,
            "name": item.name,
            "quantity": item.quantity,
            "price": item.price,
            "special_request": item.specialRequest ?? '',
            "extras": itemExtras,
            "item_actual_price_at_order": item.price,
            "first_order_discount_applied": 0,
          };
        }).toList(),
      };

      final response = await dio.post(
        "/api/orders/place",
        data: orderData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final success = response.data['success'] == true;
      final message = response.data['message'];

      if (success) {
        currentCartData = null;
        emit(OrderPlacedSuccess(message: message ?? "Order placed successfully!"));
        await fetchCart();
      } else {
        emit(CartError(message ?? "Failed to place order."));
      }
    } on DioException catch (e) {
      print("Error placing order: ${e.response?.data ?? e.message}");
      emit(CartError(e.response?.data['message'] ?? e.response?.data['error'] ?? "Failed to place order."));
    } catch (e) {
      print("Unexpected error placing order: $e");
      emit(CartError("An unexpected error occurred while placing order: ${e.toString()}"));
    }
  }


  Future<void> addToCart({
    required int productId,
    required int quantity,
    String? specialRequest,
    List<Map<String, dynamic>> extras = const [],
    // removed productCreatorId from here, the backend determines it from productId
  }) async {
    final token = CacheHelper.getData(key: 'userToken');
    if (token == null) {
      emit(CartError("User not authenticated. Please log in."));
      return;
    }

    emit(AddCartLoading());
    try {
      final response = await dio.post(
        "/api/cart/add",
        data: {
          "product_id": productId,
          "quantity": quantity,
          "special_request": specialRequest,
          "extras": extras,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final success = response.data['success'] == true;
      final message = response.data['message'];

      if (success) {

        await fetchCart();
        emit(AddCartLoaded(message: message ?? "Product added to cart successfully."));
      } else {
        emit(CartError(message ?? "Failed to add to cart."));
      }

    } on DioException catch (e) {
      print("Failed to add to cart: ${e.response?.data ?? e.message}");
      emit(CartError(e.response?.data['message'] ?? e.response?.data['error'] ?? "Failed to add to cart."));
    } catch (e) {
      print("Unexpected error adding to cart: $e");
      emit(CartError("An unexpected error occurred while adding to cart: ${e.toString()}"));
    }
  }


  Future<void> removeFromCart(int cartItemId) async {
    final token = CacheHelper.getData(key: 'userToken');
    if (token == null) {
      emit(CartError("User not authenticated. Please log in."));
      return;
    }
    emit(CartLoading());
    try {
      final response = await dio.delete(
        "/api/cart/remove/$cartItemId",
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      final success = response.data['success'] == true;
      final message = response.data['message'];
      if (success) {
        emit(CartItemRemoved(message: message ?? "Item removed from cart successfully."));
      } else {
        emit(CartError(message ?? "Failed to remove item."));
      }
    } on DioException catch (e) {
      print("Failed to remove item from cart: ${e.response?.data ?? e.message}");
      emit(CartError(e.response?.data['message'] ?? e.response?.data['error'] ?? "Failed to remove item."));
    } catch (e) {
      print("Unexpected error removing item from cart: $e");
      emit(CartError("An unexpected error occurred while removing item: ${e.toString()}"));
    }
  }

  // ----------------------------------------------------
  //                     updateCartItemQuantity
  // ----------------------------------------------------
  Future<void> updateCartItemQuantity({
    required int cartId,
    required int quantity,
  }) async {
    final token = CacheHelper.getData(key: 'userToken');
    if (token == null) {
      emit(CartError("User not authenticated. Please log in."));
      return;
    }
    if (quantity <= 0) {
      emit(CartError("Quantity must be a positive number."));
      return;
    }

    emit(CartLoading());
    try {
      final response = await dio.put(
        "/api/cart/update-quantity/$cartId",
        data: {"quantity": quantity},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final success = response.data['success'] == true;
      final message = response.data['message'];

      if (success) {
        await fetchCart();
        emit(CartLoaded(
          cart: currentCartData!,
          creatorInfo: (state is CartLoaded) ? (state as CartLoaded).creatorInfo : null,
        ));
      } else {
        emit(CartError(message ?? "Failed to update quantity."));
      }
    } on DioException catch (e) {
      print("Failed to update cart item quantity: ${e.response?.data ?? e.message}");
      emit(CartError(e.response?.data['message'] ?? e.response?.data['error'] ?? "Failed to update quantity."));
    } catch (e) {
      print("Unexpected error updating cart item quantity: $e");
      emit(CartError("An unexpected error occurred while updating quantity: ${e.toString()}"));
    }
  }


  Future<void> clearCart() async {
    final userId = CacheHelper.getData(key: 'userIdTwo');
    final token = CacheHelper.getData(key: 'userToken');
    if (userId == null || token == null) {
      emit(CartError("User not authenticated. Please log in."));
      return;
    }

    emit(CartLoading());
    try {
      final response = await dio.delete(
        "/api/cart/clear/$userId",
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final success = response.data['success'] == true;
      final message = response.data['message'];

      if (success) {
        currentCartData = null;
        emit(CartLoaded(
          cart: const CartDataModel(items: [], subtotal: '0.00', deliveryFee: '0.00', discountAmount: '0.00', total: '0.00', creatorPaymentMethods: []),
          creatorInfo: null,
        ));

      } else {
        emit(CartError(message ?? "Failed to clear cart."));
      }
    } on DioException catch (e) {
      print("Failed to clear cart: ${e.response?.data ?? e.message}");
      emit(CartError(e.response?.data['message'] ?? e.response?.data['error'] ?? "Failed to clear cart."));
    } catch (e) {
      print("Unexpected error clearing cart: $e");
      emit(CartError("An unexpected error occurred while clearing cart: ${e.toString()}"));
    }
  }

  void initializeCart() {
    emit(CartLoading());
    fetchCart();
  }
}
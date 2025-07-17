import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../../core/theme/icons_broken.dart';
import 'CartCubit.dart';
import 'CartState.dart';

class CartIconWithBadge extends StatelessWidget {
  const CartIconWithBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final itemCount = state is CartLoaded
            ? state.cart.items.length
            : 0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              child: IconButton(
                icon: Icon(
                  IconBroken.Buy,
                  color: Colors.black,
                  size: 24,
                ),
                onPressed: () {
                  context.read<CartCubit>().fetchCart();
                  context.push('/CartScreen');
                },
              ),
            ),

            // Badge
            if (itemCount > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red[600],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Center(
                    child: Text(
                      itemCount > 9 ? '9+' : '$itemCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
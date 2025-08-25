import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../../core/helper/user_data_manager.dart';
import '../../../../../../../core/network/local/cach_helper.dart';
import '../../../../../../../core/theme/icons_broken.dart';
import '../../../../../../../core/theme/color.dart';

import '../../../../../../widgets/compnents.dart';
import '../../../../../../widgets/coustem_form_input.dart';

import 'CartCubit.dart';
import 'CartState.dart';

import '../../../profile_screens/logic/address_cubit.dart';
import '../../../profile_screens/logic/address_state.dart';

import '../../../../../../../data/models/user_items_model/card_models/creator_payment_method_model.dart';
import '../../../../../../../data/models/user_items_model/cart_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String? _selectedPaymentMethod;
  String? _selectedAddress;
  bool _hasAddress = false;
  final TextEditingController _notesController = TextEditingController();
  late bool isGuest;

  @override
  void initState() {
    super.initState();

    // تحديد وضع الضيف
    final userToken = CacheHelper.getData(key: 'userToken');
    isGuest = (CacheHelper.getData(key: 'guest') == true) || (userToken == null);

    if (isGuest) {
    } else {
      context.read<CartCubit>().fetchCart();
      context.read<UserAddressCubit>().fetchUserAddress();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }




  // ======= UI =======
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text('my_cart'.tr(), style: const TextStyle(fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        leading: popButton(context),
      ),

      // إذا ضيف: اعرض Placeholder مع زر تسجيل دخول
      body: isGuest
          ? _GuestCartPlaceholder(
        onSignIn: () {
          CacheHelper.saveData(key: 'guest', value: false);
          context.go('/choose');
        },
      )
          : BlocConsumer<CartCubit, CartState>(
        listener: (context, state) {
          if (state is CartError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message.tr())),
            );
          }

          if (state is OrderPlacedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message.tr(),
                  style: const TextStyle(color: Colors.black),
                ),
                backgroundColor: Theme.of(context).primaryColor,
              ),
            );
            context.go('/ConfirmedOrder');
          }

          final userAddressState = context.read<UserAddressCubit>().state;
          if (userAddressState is UserAddressLoaded) {
            final user = userAddressState.user;
            if ((user.city ?? '').isNotEmpty ||
                (user.street ?? '').isNotEmpty ||
                (user.country ?? '').isNotEmpty) {
              final fullAddress =
              _buildAddressString(user.city, user.street, user.country);
              _selectedAddress = fullAddress;
              _hasAddress = true;
            } else {
              _hasAddress = false;
            }
          } else {
            _hasAddress = false;
          }
        },
        builder: (context, state) {
          final cubit = context.read<CartCubit>();

          if (state is CartLoading || state is OrderPlacing) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CartLoaded) {
            final cartData = state.cart;
            final items = cartData.items;

            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 250,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 80),
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(width: 2, color: textColor),
                          ),
                          child: Icon(IconBroken.Buy,
                              size: 80, color: textColor),
                        ),
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red[600],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            child: const Center(
                              child: Text(
                                '0',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'cart_empty'.tr(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'add_items_to_start'.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 220,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => context.go('/UserLayout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'browse_products'.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // محتوى السلة الفعلي
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        _buildDeliverySection(context),
                        const SizedBox(height: 12),
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                          itemBuilder: (_, index) => _buildCartItem(
                            context,
                            items[index],
                            cubit,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                _buildOrderSummary(
                  subtotal: double.parse(cartData.subtotal),
                  deliveryFee: double.parse(cartData.deliveryFee),
                  discountAmount: double.parse(cartData.discountAmount),
                  discountMessage: cartData.discountMessage,
                  finalTotal: double.parse(cartData.total),
                  creatorPaymentMethods: cartData.creatorPaymentMethods,
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  String _buildAddressString(String? city, String? street, String? country) {
    final parts = <String>[];
    if ((city ?? '').isNotEmpty) parts.add(city!);
    if ((street ?? '').isNotEmpty) parts.add(street!);
    if ((country ?? '').isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }

  Widget _buildDeliverySection(BuildContext context) {
    return BlocBuilder<UserAddressCubit, UserAddressState>(
      builder: (context, addressState) {
        if (addressState is UserAddressLoaded) {
          final user = addressState.user;
          if ((user.city ?? '').isNotEmpty ||
              (user.street ?? '').isNotEmpty ||
              (user.country ?? '').isNotEmpty) {
            final fullAddress =
            _buildAddressString(user.city, user.street, user.country);
            _selectedAddress = fullAddress;
            _hasAddress = true;

            return Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                          Theme.of(context).primaryColor.withOpacity(0.2),
                          child: Icon(
                            Icons.location_on_outlined,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'delivery_address'.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => context.push('/AddressScreen'),
                          child: Text(
                            'change'.tr(),
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_city,
                            size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            fullAddress,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomFormInput(
                      controller: _notesController,
                      hintText: 'add_delivery_instructions_optional'.tr(),
                      prefixIcon: Icons.sticky_note_2_rounded,
                      maxLines: 1,
                      label: '',
                      validator: (_) => null,
                      borderRadius: 5,
                      hintFontSize: 13.5,
                    ),
                  ],
                ),
              ),
            );
          }

          _hasAddress = false;
          return _buildNoAddressCard(context);
        } else if (addressState is AddressError) {
          _hasAddress = false;
          return _buildNoAddressCard(context);
        } else if (addressState is UserAddressLoading ||
            addressState is UserAddressInitial) {
          _hasAddress = false;
          return const Center(child: CircularProgressIndicator());
        }

        _hasAddress = false;
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildNoAddressCard(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.location_on_outlined, color: textColor),
                const SizedBox(width: 8),
                Text('delivery_address'.tr(),
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'no_address_found'.tr(),
              style: const TextStyle(
                  fontSize: 13, color: Colors.red, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.push('/AddressScreen'),
                child: Text('add_address'.tr(),
                    style: TextStyle(color: textColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(
      BuildContext context,
      CartItem item,
      CartCubit cubit,
      ) {
    final displayItemPrice = item.price + item.extrasTotalPerItem;

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.pictures.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.pictures.first,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade300,
                        child: Icon(Icons.broken_image,
                            color: Colors.grey.shade600),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.image_not_supported,
                        color: Colors.grey.shade500),
                  ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${displayItemPrice.toStringAsFixed(2)} x ${item.quantity}',
                        style:
                        TextStyle(color: textColor, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${'total'.tr()}: \$${item.itemTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: textColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildQuantityButton(
                              Icons.remove,
                                  () {
                                if (item.quantity > 1) {
                                  cubit.updateCartItemQuantity(
                                    cartId: item.cartId,
                                    quantity: item.quantity - 1,
                                  );
                                } else {
                                  cubit.removeFromCart(item.cartId);
                                }
                              },
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                item.quantity.toString(),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            _buildQuantityButton(
                              Icons.add,
                                  () => cubit.updateCartItemQuantity(
                                cartId: item.cartId,
                                quantity: item.quantity + 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: CircleAvatar(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    child:
                    Icon(Icons.delete_outline, color: Colors.red.shade700),
                  ),
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext ctx) {
                        return AlertDialog(
                          backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                          title: Row(
                            children: [
                              const Icon(Icons.delete_forever_rounded,
                                  color: Colors.red, size: 40),
                              const SizedBox(width: 10),
                              Text('deleteOrder'.tr(),
                                  style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                          actionsAlignment: MainAxisAlignment.center,
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: Text(
                                'cancel'.tr(),
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            TextButton(
                              onPressed: () {
                                cubit.removeFromCart(item.cartId).then((_) {
                                  Navigator.of(ctx).pop();
                                  context.push('/CartScreen');
                                });
                              },
                              child: Text(
                                'delete'.tr(),
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'remove_item'.tr(),
                ),
              ],
            ),
            if (item.extras.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'extras'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: item.extras
                    .map(
                      (extra) => Chip(
                    label: Text(
                      '${extra.name} (\$${extra.price.toStringAsFixed(2)})',
                      style: TextStyle(fontSize: 12, color: textColor),
                    ),
                    backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.1),
                    labelStyle: TextStyle(color: textColor),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.5),
      ),
      child: IconButton(
        icon: Icon(icon, size: 18, color: Colors.black),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildOrderSummary({
    required double subtotal,
    required double deliveryFee,
    required double discountAmount,
    String? discountMessage,
    required double finalTotal,
    required List<CreatorPaymentMethodModel> creatorPaymentMethods,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Text('subtotal'.tr()),
              const Spacer(),
              Text('\$${subtotal.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'total'.tr(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '\$${finalTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ExpansionTile(
            title: Text('order_details'.tr()),
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            initiallyExpanded: false,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  Row(
                    children: [
                      Icon(Icons.delivery_dining, color: textColor, size: 16),
                      const SizedBox(width: 10),
                      Text('delivery_fee'.tr()),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    deliveryFee == 0.0
                        ? 'free'.tr()
                        : '\$${deliveryFee.toStringAsFixed(2)}',
                    style: deliveryFee == 0.0
                        ? const TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold)
                        : null,
                  ),
                ],
              ),
              if (discountAmount > 0) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.discount, color: textColor, size: 15),
                        const SizedBox(width: 10),
                        Text('discount'.tr()),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '-\$${discountAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if ((discountMessage ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: textColor),
                        color:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                      child: Text(
                        discountMessage!.tr(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[900],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ],
          ),
          const SizedBox(height: 20),
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              final isLoading = state is OrderPlacing;
              return SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  onPressed: isLoading || !_hasAddress
                      ? null
                      : () => _placeOrder(
                    context,
                    creatorPaymentMethods,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(
                    'place_order'.tr(),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _placeOrder(
      BuildContext context,
      List<CreatorPaymentMethodModel> creatorPaymentMethods,
      ) async {
    final addressState = context.read<UserAddressCubit>().state;
    if (addressState is UserAddressLoaded) {
      final currentUserAddress = addressState.user;
      _selectedAddress = _buildAddressString(
        currentUserAddress.city,
        currentUserAddress.street,
        currentUserAddress.country,
      );
    }

    if ((_selectedAddress ?? '').isEmpty) {
      await _showAddressErrorDialog(context);
      return;
    }

    final user = UserDataManager.getUserModel();
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('user_info_missing'.tr())),
      );
      return;
    }

    String userName =
    '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
    if (userName.isEmpty) userName = 'Unknown User';

    String? userPhone = user.phone;
    if ((userPhone ?? '').isEmpty) {
      final shouldUpdatePhone = await _showPhoneNumberRequiredDialog(context);
      if (shouldUpdatePhone ?? false) {
        if (mounted) context.push('/PersonalInfoScreen');
      }
      return;
    }

    await _showOrderConfirmationDialog(
      context,
      userName,
      userPhone!,
    );
  }

  Future<bool?> _showPhoneNumberRequiredDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'phone_number_required'.tr(),
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
        content: Text('please_add_phone_number_to_continue'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'cancel'.tr(),
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'add_phone_number'.tr(),
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddressErrorDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('address_required'.tr()),
        content: Text('please_add_delivery_address_to_continue'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/AddressScreen');
            },
            child: Text('add_address'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _showOrderConfirmationDialog(
      BuildContext context,
      String userName,
      String userPhone,
      ) {
    final TextEditingController notesController = TextEditingController();
    final primaryColor = Theme.of(context).primaryColor;

    return showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Container(
          width: MediaQuery.of(ctx).size.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [textColor, Theme.of(context).primaryColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.white, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            'confirm_order'.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 180,
                            ),
                          ),
                          const SizedBox(height: 30),
                          _buildSection(
                            icon: Icons.location_on_outlined,
                            title: 'deliver_to'.tr(),
                            content: _selectedAddress ??
                                'no_address_selected'.tr(),
                          ),
                          const SizedBox(height: 20),
                          _buildSection(
                            icon: Icons.payment,
                            title: 'payment_method'.tr(),
                            content:
                            'you_will_choose_payment_after_approval'.tr(),
                          ),
                          const SizedBox(height: 20),
                          // بإمكانك إضافة حقل ملاحظات هنا لو رغبت
                        ],
                      ),
                    ),

                    // Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Column(
                        children: [
                          BlocBuilder<CartCubit, CartState>(
                            builder: (context, cartState) {
                              final isPlacingOrder = cartState is OrderPlacing;
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                    elevation: 2,
                                  ),
                                  onPressed: isPlacingOrder
                                      ? null
                                      : () async {
                                    Navigator.pop(ctx);
                                    await context
                                        .read<CartCubit>()
                                        .placeOrder(
                                      shippingAddress:
                                      _selectedAddress!,
                                      userName: userName,
                                      userPhone: userPhone,
                                      notes: notesController.text,
                                    );
                                  },
                                  child: isPlacingOrder
                                      ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                      : Text(
                                    'confirm_order'.tr(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey[400]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding:
                                const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(
                                'cancel'.tr(),
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.grey[700], size: 22),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 34),
          child: Text(
            content,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}

// واجهة ضيف للسلة
class _GuestCartPlaceholder extends StatelessWidget {
  final VoidCallback onSignIn;
  const _GuestCartPlaceholder({required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', width: 200),
            const SizedBox(height: 28),
            Icon(Icons.lock_outline, size: 54, color: textColor),
            const SizedBox(height: 16),
            Text(
              'guest_cart_title'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'guest_cart_subtitle'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withOpacity(0.75),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'sign_in_or_create'.tr(),
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => context.go('/UserLayout'),
              child: Text(
                'browse_products'.tr(),
                style: TextStyle(fontWeight: FontWeight.w600  , color:textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

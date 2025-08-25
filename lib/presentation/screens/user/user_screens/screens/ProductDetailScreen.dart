import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/theme/LocaleKeys.dart';
import '../../../../../core/theme/color.dart';
import '../../../../../core/network/local/cach_helper.dart';
import '../../../../../data/creatorsItems.dart';
import '../../../../../data/models/items_model/restaurant_item_details.dart';
import '../../../../../data/models/user_items_model/items.dart';

import 'items_logic/items_get_cubit.dart';
import 'items_logic/items_git_states.dart';

import 'orders/cart/CartCubit.dart';
import 'orders/cart/CartIconWithBadge.dart';
import 'orders/cart/CartState.dart';
import 'orders/cart/cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productName;
  final double productPrice;
  final String productDescription;
  final int itemId;
  final CreatorItem creator;
  final bool isAvailable;
  final int professionId;
  final String? portfolioLink;
  final String? syllabus;

  const ProductDetailScreen({
    Key? key,
    required this.productName,
    required this.productPrice,
    required this.productDescription,
    required this.itemId,
    required this.creator,
    required this.isAvailable,
    required this.professionId,
    this.portfolioLink,
    this.syllabus,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  bool _isAddingToCart = false;
  final TextEditingController commentController = TextEditingController();
  final _imageCacheDuration = const Duration(hours: 24);

  List<Ingredient> selectedExtras = [];
  late bool isGuest;

  bool get _canAddToCartBasedOnCartState {
    final cartState = context.read<CartCubit>().state;
    final cartIsEmpty = cartState is CartInitial ||
        (cartState is CartLoaded && cartState.cart.items.isEmpty);
    final isSameCreator = cartState is CartLoaded &&
        cartState.cart.items.isNotEmpty &&
        cartState.cart.items.first.creatorId == widget.creator.id;

    return cartIsEmpty || isSameCreator;
  }

  bool get _isButtonActive {
    // مهم: الضيف ما لازم يقدر يضيف للسلة
    return widget.isAvailable && _canAddToCartBasedOnCartState && !isGuest;
  }

  void toggleExtra(Ingredient ingredient) {
    setState(() {
      if (selectedExtras.contains(ingredient)) {
        selectedExtras.remove(ingredient);
      } else {
        selectedExtras.add(ingredient);
      }
    });
  }

  double get totalPrice {
    final basePrice = widget.productPrice;
    final extrasPrice =
    selectedExtras.fold(0.0, (sum, ingredient) => sum + ingredient.price);
    return (basePrice + extrasPrice) * quantity;
  }

  void _checkAvailability() {
    debugPrint('Checking product availability...');
    debugPrint('Product ID: ${widget.itemId}');
    debugPrint('Is Available: ${widget.isAvailable}');
    debugPrint('Creator: ${widget.creator.storeName}');
    debugPrint('Current Time: ${DateTime.now()}');
  }

  @override
  void initState() {
    super.initState();
    _checkAvailability();

    // تحديد وضع الضيف
    final userToken = CacheHelper.getData(key: 'userToken');
    isGuest = (CacheHelper.getData(key: 'guest') == true) || (userToken == null);

    context.read<UserItemsCubit>().fetchItemsByProfessionId(widget.creator.id);
    context.read<CartCubit>().initializeCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.productName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: CartIconWithBadge(),
          ),
        ],
        leading: _buildBackButton(),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: BlocConsumer<UserItemsCubit, UserItemsState>(
            listener: (context, state) {
              if (state is UserItemsError) {
                _showErrorSnackBar(context, state.message);
              }
            },
            builder: (context, state) {
              if (state is UserItemsLoading) {
                return _buildShimmerLoading();
              } else if (state is UserItemsLoaded) {
                try {
                  final item =
                  state.items.firstWhere((it) => it.id == widget.itemId);
                  return _buildProductContent(item);
                } catch (_) {
                  return _buildEmptyState();
                }
              }
              return _buildEmptyState();
            },
          ),
        ),
      ),
      bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
        builder: (context, cartState) {
          final cartCubit = context.read<CartCubit>();
          final int? currentCartCreatorId = cartCubit.currentCartData != null &&
              cartCubit.currentCartData!.items.isNotEmpty
              ? cartCubit.currentCartData!.items.first.creatorId
              : null;

          final canAddToCart =
              currentCartCreatorId == null || currentCartCreatorId == widget.creator.id;

          return _buildBottomBar(canAddToCart, cartCubit);
        },
      ),
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildProductContent(Item item) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductImage(item),
                _buildProductHeader(item),
                _buildDivider(),
                if (widget.professionId == 5) _buildPortfolioSection(),
                if (widget.professionId != 5 && widget.professionId != 6)
                  _buildDescriptionSection(),
                if (widget.professionId == 6) _buildSyllabusSection(),
                if (item.restaurantIngredients?.isNotEmpty ?? false)
                  _buildAddOnsSection(item),
                _buildSpecialRequestSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductImage(Item item) {
    return Hero(
      tag: 'product-image-${item.id}',
      child: Container(
        height: 250,
        width: double.infinity,
        color: Colors.grey[200],
        child: item.pictures.isNotEmpty
            ? CachedNetworkImage(
          imageUrl: item.pictures[0],
          fit: BoxFit.cover,
          progressIndicatorBuilder: (context, url, progress) =>
              Center(child: CircularProgressIndicator(value: progress.progress)),
          errorWidget: (_, __, ___) =>
              Icon(Icons.image_not_supported, size: 60, color: Colors.grey[400]),
        )
            : Icon(Icons.image_not_supported, size: 60, color: Colors.grey[400]),
      ),
    );
  }

  Widget _buildProductHeader(Item item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildCreatorInfo(),
        ],
      ),
    );
  }

  Widget _buildCreatorInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundImage: widget.creator.profileImage.isNotEmpty
              ? NetworkImage(widget.creator.profileImage)
              : const AssetImage('assets/images/default_profile.png') as ImageProvider,
        ),
        const SizedBox(width: 8),
        Text(
          widget.creator.storeName,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey[200], indent: 20, endIndent: 20);
  }

  Widget _buildDescriptionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('description'.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            widget.productDescription,
            style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
          ),
          const SizedBox(height: 16),
          _buildPriceSummary(),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          _buildPriceRow('itemPrice'.tr(), widget.productPrice),
          _buildPriceRow('quantity'.tr(), quantity.toDouble(), isQuantity: true),
          if (selectedExtras.isNotEmpty)
            ...selectedExtras.map((e) => _buildPriceRow('+ ${e.name}', e.price.toDouble())),
          const Divider(),
          _buildPriceRow('Total', totalPrice, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSyllabusSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Syllabus'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).primaryColor),
            ),
            child: Text(
              '${widget.syllabus}',
              maxLines: 3,
              style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5, overflow: TextOverflow.ellipsis),
            ),
          ),
          const SizedBox(height: 16),
          _buildSyllabusSummary(),
        ],
      ),
    );
  }

  Widget _buildSyllabusSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(children: [_buildPriceRow('Course price', totalPrice, isTotal: true)]),
    );
  }

  Widget _buildPortfolioSection() {
    if (widget.portfolioLink != null && widget.portfolioLink!.isNotEmpty) {
      List<dynamic> parsedLinks;
      try {
        parsedLinks = jsonDecode(widget.portfolioLink!);
      } catch (e) {
        parsedLinks = [];
      }

      if (parsedLinks.isNotEmpty && parsedLinks[0] is String) {
        final String rawLink = parsedLinks[0];

        String formattedLinkForLaunch = rawLink;
        if (!formattedLinkForLaunch.startsWith('http://') &&
            !formattedLinkForLaunch.startsWith('https://')) {
          formattedLinkForLaunch = 'https://$formattedLinkForLaunch';
        }

        final Uri urlToLaunch = Uri.parse(formattedLinkForLaunch);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Portfolio Link'.tr(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.zero,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () async {
                    try {
                      if (await canLaunchUrl(urlToLaunch)) {
                        await launchUrl(urlToLaunch, mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Could not open $rawLink'.tr(),
                                style: const TextStyle(color: Colors.black)),
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to open link: ${e.toString()}'.tr())),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.link, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            rawLink,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        Icon(Icons.open_in_new, color: Colors.grey[600], size: 18),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildPortfolioSummary(),
            ],
          ),
        );
      }
    }
    return const SizedBox.shrink();
  }

  Widget _buildPortfolioSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(children: [_buildPriceRow('Total', totalPrice, isTotal: true)]),
    );
  }

  Widget _buildPriceRow(String label, double value,
      {bool isTotal = false, bool isQuantity = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? Colors.black : Colors.grey[700],
              )),
          isQuantity
              ? _buildQuantitySelector()
              : Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? textColor : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            splashRadius: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => setState(() => quantity = quantity > 1 ? quantity - 1 : 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('$quantity',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            splashRadius: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => setState(() => quantity++),
          ),
        ],
      ),
    );
  }

  Widget _buildAddOnsSection(Item item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('add_ons'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('select_extras'.tr(), style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              Text(" (${'optional'.tr()})",
                  style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ...item.restaurantIngredients!.map(_buildAddOnItem).toList(),
        ],
      ),
    );
  }

  Widget _buildAddOnItem(Ingredient ingredient) {
    final isSelected = selectedExtras.contains(ingredient);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => toggleExtra(ingredient),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
            isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? textColor : Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (_) => toggleExtra(ingredient),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                activeColor: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ingredient.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? textColor : Colors.black,
                        )),
                    const SizedBox(height: 4),
                    Text('\$${ingredient.price.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 14, color: isSelected ? textColor : Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialRequestSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('special_requests'.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('special_instructions_desc'.tr(),
              style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${"write_special_instructions".tr()}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textColor)),
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: InputBorder.none, contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool canAddToCart, CartCubit cartCubit) {
    final String buttonLabel;
    if (!widget.isAvailable) {
      buttonLabel = 'closed'.tr();
    } else if (isGuest) {
      // الضيف
      buttonLabel = 'add_to_cart'.tr(); // بيظهر نص طبيعي، لكن onPressed يفتح Sheet
    } else if (!_canAddToCartBasedOnCartState) {
      buttonLabel = 'clear_cart_to_add'.tr();
    } else {
      buttonLabel = '${"add_to_cart".tr()} - \$${totalPrice.toStringAsFixed(2)}';
    }

    final bool enabled =
        widget.isAvailable && _canAddToCartBasedOnCartState && !isGuest;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (isGuest) {
                    _showLoginRequiredSheet(); // الضيف → BottomSheet
                  } else if (enabled) {
                    _handleAddToCart(context);
                  } else {
                    if (!widget.isAvailable) {
                      _showErrorSnackBar(context, 'closed'.tr());
                    } else {
                      _showDifferentCreatorDialog(context.read<CartCubit>());
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor:
                  enabled ? Theme.of(context).primaryColor : Colors.grey[400],
                ),
                child: _isAddingToCart
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  buttonLabel,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLoginRequiredSheet() async {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 44,
              width: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
              ),
              child: Icon(
                Icons.lock_outline,
                size: 24,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              LocaleKeys.auth_login_required_title.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              LocaleKeys.auth_login_required_subtitle.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),

                    ),
                    child: Text(
                      LocaleKeys.auth_continue_as_guest.tr(),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14 , color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      CacheHelper.saveData(key: 'guest', value: false);
                      context.push('/choose');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      LocaleKeys.auth_sign_in_or_create.tr(),
                      style: const TextStyle(fontWeight: FontWeight.w600 , color: Colors.black , fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDifferentCreatorDialog(CartCubit cartCubit) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text('different_creator_title'.tr(),
              style: const TextStyle(fontSize: 16)),
          content: Text('different_creator_message'.tr()),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('cancel'.tr(),
                  style: const TextStyle(color: Colors.red, fontSize: 16)),
            ),
            TextButton(
              onPressed: () {
                cartCubit.clearCart();
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        'cart_cleared_successfully'.tr(),
                        style: const TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
              },
              child: Text('clear_cart'.tr(),
                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: ListView(
        children: [
          Container(height: 250, width: double.infinity, color: Colors.white),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SizedBox(height: 28, width: double.infinity, child: ColoredBox(color: Colors.white)),
                SizedBox(height: 16),
                SizedBox(height: 20, width: 150, child: ColoredBox(color: Colors.white)),
                SizedBox(height: 24),
                SizedBox(height: 16, width: double.infinity, child: ColoredBox(color: Colors.white)),
                SizedBox(height: 8),
                SizedBox(height: 16, width: double.infinity, child: ColoredBox(color: Colors.white)),
                SizedBox(height: 8),
                SizedBox(height: 16, width: 200, child: ColoredBox(color: Colors.white)),
                SizedBox(height: 24),
                SizedBox(height: 100, width: double.infinity, child: ColoredBox(color: Colors.white)),
                SizedBox(height: 24),
                SizedBox(height: 16, width: double.infinity, child: ColoredBox(color: Colors.white)),
                SizedBox(height: 8),
                SizedBox(height: 16, width: double.infinity, child: ColoredBox(color: Colors.white)),
                SizedBox(height: 24),
                SizedBox(height: 50, width: double.infinity, child: ColoredBox(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text(
            widget.isAvailable ? 'loading_product'.tr() : 'product_not_available'.tr(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          if (widget.isAvailable)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Future<void> _handleAddToCart(BuildContext context) async {
    if (isGuest) {
      _showLoginRequiredSheet();
      return;
    }

    setState(() => _isAddingToCart = true);
    final cubit = context.read<CartCubit>();

    if (!widget.isAvailable) {
      _showErrorSnackBar(context, 'closed'.tr());
      setState(() => _isAddingToCart = false);
      return;
    }

    final itemCubit = context.read<UserItemsCubit>();
    final item = itemCubit.state is UserItemsLoaded
        ? (itemCubit.state as UserItemsLoaded).items.firstWhere(
          (it) => it.id == widget.itemId,
      orElse: () => (itemCubit.state as UserItemsLoaded).items[0],
    )
        : null;

    if (item == null) {
      _showErrorSnackBar(context, 'product_info_not_available'.tr());
      setState(() => _isAddingToCart = false);
      return;
    }

    try {
      await cubit.addToCart(
        productId: item.id,
        quantity: quantity,
        specialRequest: commentController.text,
        extras: selectedExtras
            .map((e) => {'name': e.name, 'price': e.price})
            .toList(),
      );
      _showSuccessSnackBar(context, cubit.state);
    } catch (e) {
      _showErrorSnackBar(context, e.toString());
    } finally {
      setState(() => _isAddingToCart = false);
    }
  }

  void _showSuccessSnackBar(BuildContext context, CartState state) {
    String snackBarMessage = 'added_to_cart_successfully'.tr();

    if (state is AddCartLoaded) {
      snackBarMessage = state.message;
    } else if (state is OrderPlacedSuccess) {
      snackBarMessage = state.message;
      context.read<CartCubit>().fetchCart();
    } else if (state is CartItemRemoved) {
      snackBarMessage = state.message;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.black),
            const SizedBox(width: 8),
            Expanded(
              child: Text(snackBarMessage, style: const TextStyle(color: Colors.black)),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'view_cart'.tr(),
          textColor: Colors.black,
          onPressed: _navigateToCartScreen,
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
          ],
        ),
      ),
    );
  }

  void _navigateToCartScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
  }
}

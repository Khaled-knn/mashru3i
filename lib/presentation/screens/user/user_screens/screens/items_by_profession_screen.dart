import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart'; // <-- مهم لفورمات بديلة في البارسِر
import 'package:mashrou3i/core/theme/color.dart';
import 'package:mashrou3i/presentation/widgets/custom_button.dart';
import '../../../../../core/theme/icons_broken.dart';
import '../../../../../data/creatorsItems.dart';
import '../../../../widgets/compnents.dart';
import 'SearchFilterScreen.dart';
import 'favorites/FavoriteCreatorsScreen.dart';
import 'favorites/FavoritesCubit.dart';
import 'items_logic/items_by_creatorId_screen.dart';
import 'items_logic/items_get_cubit.dart';
import 'items_logic/items_git_states.dart';
import 'orders/cart/CartCubit.dart';
import 'orders/cart/CartIconWithBadge.dart';

class ItemsByProfessionScreen extends StatefulWidget {
  final String title;
  final int professionId;

  const ItemsByProfessionScreen({
    Key? key,
    required this.title,
    required this.professionId,
  }) : super(key: key);

  @override
  State<ItemsByProfessionScreen> createState() => _ItemsByProfessionScreenState();
}

class _ItemsByProfessionScreenState extends State<ItemsByProfessionScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  StreamSubscription<UserItemsState>? _subscription; // <-- صار nullable لتفادي التسريب
  List<CreatorItem> creators = [];
  bool _isLoading = true;
  String? _error;
  bool _initialLoadComplete = false;

  String? _currentSearchQuery;
  double? _currentMinRate;
  bool _currentFreeDelivery = false;
  bool _currentHasOffer = false;
  bool _currentIsOpenNow = false;

  @override
  void initState() {
    super.initState();
    _loadCreators();
    context.read<CartCubit>().initializeCart();
  }

  void _loadCreators({
    String? search,
    double? minRate,
    bool freeDelivery = false,
    bool hasOffer = false,
    bool isOpenNow = false,
  }) {
    _currentSearchQuery = search;
    _currentMinRate = minRate;
    _currentFreeDelivery = freeDelivery;
    _currentHasOffer = hasOffer;
    _currentIsOpenNow = isOpenNow;

    final cubit = context.read<UserItemsCubit>();

    // ألغِ أي اشتراك قديم قبل إنشاء واحد جديد
    _subscription?.cancel();
    _subscription = cubit.stream.listen((state) {
      if (state is UserCreatorsLoading) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      } else if (state is UserCreatorsLoaded) {
        setState(() {
          creators = state.items;
          _isLoading = false;
          _initialLoadComplete = true;
        });
      } else if (state is UserCreatorsError) {
        setState(() {
          _error = state.message;
          _isLoading = false;
          _initialLoadComplete = true;
        });
      }
    });

    cubit.fetchCreatorByProfessionId(
      widget.professionId,
      search: search,
      minRate: minRate,
      freeDelivery: freeDelivery,
      hasOffer: hasOffer,
      isOpenNow: isOpenNow,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _navigateToSearchFilterScreen() async {
    final Map<String, dynamic>? filters = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchFilterScreen(
          categoryTitle: widget.title,
          initialSearch: _currentSearchQuery,
          initialMinRate: _currentMinRate,
          initialFreeDelivery: _currentFreeDelivery,
          initialHasOffer: _currentHasOffer,
          initialIsOpenNow: _currentIsOpenNow,
        ),
      ),
    );

    if (filters != null) {
      _loadCreators(
        search: filters['search'],
        minRate: filters['minRate'] as double?,
        freeDelivery: filters['freeDelivery'] as bool,
        hasOffer: filters['hasOffer'] as bool,
        isOpenNow: filters['isOpenNow'] as bool,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading && !_initialLoadComplete) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text('loading'.tr()),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 20),
              Text(_error!),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _loadCreators();
                  context.read<CartCubit>().initializeCart();
                },
                child: Text('retry'.tr(), style: const TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      );
    }

    if (creators.isEmpty && !_isLoading) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.store_mall_directory, size: 50, color: Colors.grey),
                const SizedBox(height: 20),
                Text('no_creators_available'.tr()),
                const SizedBox(height: 20),
                CustomButton(
                  onPressed: () {
                    context.pop();
                  },
                  text: 'Go Back',
                  width: 200,
                  textColor: Colors.black,
                  icon: Icons.arrow_back_ios_new,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  popButton(context),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: InkWell(
                                onTap: _navigateToSearchFilterScreen,
                                child: Row(
                                  children: [
                                    Icon(
                                      IconBroken.Search,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _currentSearchQuery != null && _currentSearchQuery!.isNotEmpty
                                            ? _currentSearchQuery!
                                            : '${'search_in_category'.tr()} ${widget.title}',
                                        style: TextStyle(
                                          color: _currentSearchQuery != null && _currentSearchQuery!.isNotEmpty
                                              ? Colors.black
                                              : Colors.grey,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: const BorderRadiusDirectional.only(
                                topEnd: Radius.circular(8),
                                bottomEnd: Radius.circular(8),
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(IconBroken.Filter, color: Colors.black),
                              onPressed: _navigateToSearchFilterScreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FavoriteCreatorsScreen(),
                          ),
                        );
                      },
                      icon: Icon(Icons.favorite, color: textColor),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    _loadCreators(
                      search: _currentSearchQuery,
                      minRate: _currentMinRate,
                      freeDelivery: _currentFreeDelivery,
                      hasOffer: _currentHasOffer,
                      isOpenNow: _currentIsOpenNow,
                    );
                  },
                  child: ListView.separated(
                    itemCount: creators.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final creator = creators[index];
                      final now = DateTime.now();
                      final currentDay = _getCurrentDay();
                      final currentTime = TimeOfDay.fromDateTime(now);
                      bool isAvailable = false;

                      for (final slot in creator.availability) {
                        // مبدئياً نتحقق فقط من الوقت، ولو عندك يوم لكل slot لازم تضيف شرط اليوم
                        final openTime = _parseTime(slot.openAt);
                        final closeTime = _parseTime(slot.closeAt);

                        final nowInMinutes = currentTime.hour * 60 + currentTime.minute;
                        final openInMinutes = openTime.hour * 60 + openTime.minute;
                        final closeInMinutes = closeTime.hour * 60 + closeTime.minute;

                        final isOvernight = closeInMinutes < openInMinutes;

                        if (isOvernight) {
                          if (nowInMinutes >= openInMinutes || nowInMinutes < closeInMinutes) {
                            isAvailable = true;
                            break;
                          }
                        } else {
                          if (nowInMinutes >= openInMinutes && nowInMinutes < closeInMinutes) {
                            isAvailable = true;
                            break;
                          }
                        }
                      }

                      // استبدال DateTime.parse بـ parser مرن + toLocal
                      final activeOffers = creator.offers.where((offer) {
                        try {
                          final start = _parseDateFlexible(offer.start)?.toLocal();
                          final end = _parseDateFlexible(offer.end)?.toLocal();
                          if (start == null || end == null) return false;
                          return now.isAfter(start) && now.isBefore(end);
                        } catch (e) {
                          debugPrint('Invalid offer date. start=${offer.start}, end=${offer.end}, err=$e');
                          return false;
                        }
                      }).toList();

                      final hasFreeDelivery =
                      activeOffers.any((offer) => offer.type == 'free_delivery');
                      final hasAllOrdersDiscountOffer =
                      activeOffers.any((offer) => offer.type == 'all_orders_discount');
                      final hasFirstOrderDiscount =
                      activeOffers.any((offer) => offer.type == 'first_order_discount');

                      return _buildCreatorCard(
                        context: context,
                        creator: creator,
                        isAvailable: isAvailable,
                        activeOffers: activeOffers,
                        hasFreeDelivery: hasFreeDelivery,
                        hasAllOrdersDiscountOffer: hasAllOrdersDiscountOffer,
                        hasFirstOrderDiscount: hasFirstOrderDiscount,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreatorCard({
    required BuildContext context,
    required CreatorItem creator,
    required bool isAvailable,
    required List<CreatorOffer> activeOffers,
    required bool hasFreeDelivery,
    required bool hasAllOrdersDiscountOffer,
    required bool hasFirstOrderDiscount,
  }) {
    final now = DateTime.now();
    final String formattedAddress = _formatAddress(creator.address);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemsByCreatorIdScreen(
              creator: creator,
              professionID: widget.professionId,
              isAvailable: isAvailable,
            ),
          ),
        ).then((_) {
          if (mounted) {
            context.read<UserItemsCubit>().fetchCreatorByProfessionId(widget.professionId);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (hasAllOrdersDiscountOffer)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Center(
                    child: Transform.rotate(
                      angle: 0.785,
                      child: Text(
                        'OFFER'.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                      height: 160,
                      width: double.infinity,
                      child: creator.coverPhoto != null
                          ? CachedNetworkImage(
                        imageUrl: creator.coverPhoto!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.store,
                              size: 48,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.store,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                    // زر المفضلة
                    Positioned(
                      top: 10,
                      right: 10,
                      child: BlocBuilder<FavoriteCubit, FavoriteState>(
                        builder: (context, state) {
                          final isFavorite = state.favoriteCreatorIds.contains(creator.id);
                          return InkWell(
                            onTap: () {
                              context.read<FavoriteCubit>().toggleFavorite(creator);
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isAvailable ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                        ),
                        child: Text(
                          isAvailable ? 'open'.tr() : 'closed'.tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -40,
                      right: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: CachedNetworkImage(
                            imageUrl: creator.profileImage,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.person,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              creator.storeName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.amber.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber[700],
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  creator.rate != null ? creator.rate!.toStringAsFixed(1) : 'N/A',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  ' ( ${(creator.rateCount is num) ? (creator.rateCount as num).toStringAsFixed(0) : (creator.rateCount?.toString() ?? 'N/A')} )',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // العنوان
                      if (formattedAddress.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                formattedAddress,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),

                      if (!hasFreeDelivery)
                        if (widget.professionId != 5 && widget.professionId != 6)
                        // Show delivery value only if there's no free delivery offer
                          Row(
                            children: [
                              Icon(
                                Icons.delivery_dining,
                                size: 16,
                                color: textColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Delivery: ${creator.deliveryValue.toStringAsFixed(2)} \$',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                      if (activeOffers.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // يظهر نص "Special Offer" فقط إذا كان هناك عرض خصم على جميع الطلبات
                              if (hasAllOrdersDiscountOffer)
                                Text(
                                  '🔥 ${'special_offer'.tr()}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: activeOffers.map((offer) {
                                  final isFreeDelivery = offer.type == 'free_delivery';
                                  final isAllOrdersDiscount = offer.type == 'all_orders_discount';
                                  final isFirstOrderDiscount = offer.type == 'first_order_discount';

                                  final endDate = _parseDateFlexible(offer.end)?.toLocal();
                                  int? remainingDays;
                                  if (endDate != null) {
                                    remainingDays = endDate.difference(now).inDays;
                                  }

                                  String remainingText = '';
                                  if (!isFreeDelivery && remainingDays != null) {
                                    if (remainingDays > 0) {
                                      remainingText = ' ${"ends_in".tr(namedArgs: {"daysLeft": remainingDays.toString()})}';
                                    } else if (remainingDays == 0) {
                                      remainingText = ' ${'ends_today'.tr()}';
                                    }
                                  }

                                  Color offerColor;
                                  IconData offerIcon;
                                  String offerDescription;

                                  if (isFreeDelivery) {
                                    offerColor = Colors.teal;
                                    offerIcon = Icons.local_shipping;
                                    offerDescription = 'free_delivery_text'.tr();
                                  } else if (isAllOrdersDiscount) {
                                    offerColor = Colors.red;
                                    offerIcon = Icons.discount;
                                    final val = offer.value?.toString() ?? '0';
                                    final perc = val.contains('.') ? val.split('.')[0] : val;
                                    offerDescription = '$perc% ${'all_orders_discount_text'.tr()}';
                                  } else if (isFirstOrderDiscount) {
                                    offerColor = Colors.teal;
                                    offerIcon = Icons.star;
                                    final val = offer.value?.toString() ?? '0';
                                    final perc = val.contains('.') ? val.split('.')[0] : val;
                                    offerDescription = '$perc% ${'first_order_discount_text'.tr()}';
                                  } else {
                                    offerColor = Colors.orange;
                                    offerIcon = Icons.local_offer;
                                    offerDescription = 'special_offer_default'.tr();
                                  }

                                  // إضافة نص المدة المتبقية لجميع العروض ما عدا free_delivery
                                  offerDescription += remainingText;

                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: offerColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: offerColor,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          offerIcon,
                                          size: 16,
                                          color: offerColor,
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            offerDescription,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: offerColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to format address
  String _formatAddress(CreatorAddress? address) {
    if (address == null) {
      return '';
    }

    final parts = <String>[];
    if (address.city != null && address.city!.isNotEmpty) {
      parts.add(address.city!);
    }
    if (address.street != null && address.street!.isNotEmpty) {
      parts.add(address.street!);
    }

    return parts.join(', ');
  }

  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _getCurrentDay() {
    final now = DateTime.now();
    switch (now.weekday) {
      case DateTime.monday:
        return 'monday';
      case DateTime.tuesday:
        return 'tuesday';
      case DateTime.wednesday:
        return 'wednesday';
      case DateTime.thursday:
        return 'thursday';
      case DateTime.friday:
        return 'friday';
      case DateTime.saturday:
        return 'saturday';
      case DateTime.sunday:
        return 'sunday';
      default:
        return '';
    }
  }

  /// Parser مرن للتواريخ:
  /// - يدعم DateTime مباشرة
  /// - يدعم أرقام epoch (10 ثواني / 13 ميلي ثانية)
  /// - يحاول ISO وكم نمط شائع
  /// - يرجّع null إذا مستحيل يفسّر القيمة
  DateTime? _parseDateFlexible(dynamic input) {
    if (input == null) return null;
    if (input is DateTime) return input;

    final s = input.toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return null;

    // رقم؟ (epoch seconds/millis)
    final digits = RegExp(r'^\d{10,13}$');
    if (digits.hasMatch(s)) {
      final n = int.parse(s);
      final ms = s.length == 13 ? n : n * 1000; // 10 = ثواني، 13 = ميلي
      return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
    }

    // محاولة ISO مباشرة
    final direct = DateTime.tryParse(s);
    if (direct != null) return direct;

    // فورمات بديلة
    const patterns = [
      'yyyy-MM-dd HH:mm:ss',
      'yyyy-MM-dd HH:mm',
      'yyyy/MM/dd HH:mm:ss',
      'yyyy/MM/dd HH:mm',
      'MM/dd/yyyy HH:mm:ss',
      'MM/dd/yyyy HH:mm',
      'yyyy-MM-dd',
      'yyyy/MM/dd',
    ];
    for (final p in patterns) {
      try {
        return DateFormat(p).parseStrict(s);
      } catch (_) {}
    }

    return null;
  }
}

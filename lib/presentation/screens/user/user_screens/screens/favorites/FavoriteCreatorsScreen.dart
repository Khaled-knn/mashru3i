// lib/screens/favorite_creators_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mashrou3i/presentation/widgets/compnents.dart';

import '../../../../../../data/creatorsItems.dart';
import '../../../../../../data/models/user_items_model/CreatorAvailability.dart';
import '../items_logic/items_by_creatorId_screen.dart';
import 'FavoritesCubit.dart';

class FavoriteCreatorsScreen extends StatelessWidget {
  const FavoriteCreatorsScreen({super.key});


  String _formatAddress(CreatorAddress? address) {
    if (address == null) {
      return '';
    }
    List<String> parts = [];
    if (address.street.isNotEmpty) parts.add(address.street);
    if (address.city.isNotEmpty) parts.add(address.city);
    if (address.country.isNotEmpty) parts.add(address.country);
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: popButton(context),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('favorite_creators'.tr() , style: TextStyle(fontSize: 18),),
      ),
      body: BlocBuilder<FavoriteCubit, FavoriteState>(
        builder: (context, state) {
          final List<CreatorItem> actualFavoriteCreators = context.read<FavoriteCubit>().state.favoriteCreatorsList;


          if (actualFavoriteCreators.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'no_favorites_yet'.tr(),
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'add_favorites_description'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: actualFavoriteCreators.length,
            itemBuilder: (context, index) {
              final creator = actualFavoriteCreators[index];
              final bool isAvailable = _isCreatorCurrentlyAvailable(creator.availability);
              final List<CreatorOffer> activeOffers = _getActiveOffers(creator.offers);
              final bool hasFreeDelivery = activeOffers.any((offer) => offer.type == 'free_delivery');
              final bool hasAllOrdersDiscountOffer = activeOffers.any((offer) => offer.type == 'all_orders_discount');
              final bool hasFirstOrderDiscount = activeOffers.any((offer) => offer.type == 'first_order_discount');

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildCreatorCard(
                  context: context,
                  creator: creator,
                  isAvailable: isAvailable,
                  activeOffers: activeOffers,
                  hasFreeDelivery: hasFreeDelivery,
                  hasAllOrdersDiscountOffer: hasAllOrdersDiscountOffer,
                  hasFirstOrderDiscount: hasFirstOrderDiscount,
                  professionId: 1,
                ),
              );
            },
          );
        },
      ),
    );
  }

  bool _isCreatorCurrentlyAvailable(List<CreatorAvailability> availability) {

    return true;
  }

  List<CreatorOffer> _getActiveOffers(List<CreatorOffer> offers) {
    final now = DateTime.now();
    return offers.where((offer) {
      try {
        final startDate = DateTime.parse(offer.start);
        final endDate = DateTime.parse(offer.end);
        return now.isAfter(startDate) && now.isBefore(endDate);
      } catch (e) {
        // Handle parsing errors if date strings are invalid
        return false;
      }
    }).toList();
  }
}


Widget _buildCreatorCard({
  required BuildContext context,
  required CreatorItem creator,
  required bool isAvailable,
  required List<CreatorOffer> activeOffers,
  required bool hasFreeDelivery,
  required bool hasAllOrdersDiscountOffer,
  required bool hasFirstOrderDiscount,
  required int professionId,
}) {
  final String formattedAddress = _formatAddressHelper(creator.address);
  final Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ItemsByCreatorIdScreen(
            creator: creator,
            professionID: professionId,
            isAvailable: isAvailable,
          ),
        ),
      );
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
      child: Column(
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
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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
                if (!hasFreeDelivery && professionId != 5 && professionId != 6)
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
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

String _formatAddressHelper(CreatorAddress? address) {
  if (address == null) {
    return '';
  }
  List<String> parts = [];
  if (address.street.isNotEmpty) parts.add(address.street);
  if (address.city.isNotEmpty) parts.add(address.city);
  if (address.country.isNotEmpty) parts.add(address.country);
  return parts.join(', ');
}
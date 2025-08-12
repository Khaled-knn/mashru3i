import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mashrou3i/core/network/local/cach_helper.dart';
import 'package:mashrou3i/core/theme/LocaleKeys.dart';
import 'package:mashrou3i/core/theme/color.dart';
import 'package:mashrou3i/presentation/screens/user/user_screens/screens/items_logic/rate_screen.dart';
import '../../../../../../core/theme/icons_broken.dart';
import '../../../../../../data/creatorsItems.dart';
import '../../../../../../data/models/user_items_model/items.dart';
import '../../../../../widgets/compnents.dart';
import '../ProductDetailScreen.dart';
import '../orders/cart/CartCubit.dart';
import '../orders/cart/CartIconWithBadge.dart';
import 'items_get_cubit.dart';
import 'items_git_states.dart';

class ItemsByCreatorIdScreen extends StatefulWidget {
  final CreatorItem creator;
  final int professionID;
  final bool isAvailable;

  const ItemsByCreatorIdScreen({
    Key? key,
    required this.creator,
    required this.professionID,
    required this.isAvailable,
  }) : super(key: key);

  @override
  State<ItemsByCreatorIdScreen> createState() => _ItemsByCreatorIdScreenState();
}

class _ItemsByCreatorIdScreenState extends State<ItemsByCreatorIdScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserItemsCubit>().fetchItemsByProfessionId(widget.creator.id);
    context.read<CartCubit>().initializeCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: popButton(context),
        title:  Text(
          '${widget.creator.storeName} ${LocaleKeys.profile.tr()}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: CartIconWithBadge(),
          ),
        ],
      ),
      body: BlocConsumer<UserItemsCubit, UserItemsState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is UserItemsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserItemsLoaded) {
            final items = state.items;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCreatorProfileCard(context, items),
                  SizedBox(
                    height: 20,
                  ),
                  _buildItemsList(items),
                ],
              ),
            );
          } else if (state is UserItemsError) {
            return Center(child: Text(state.message));
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
              ],
            ),
          );
        },
      ),
    );
  }
  Widget _buildCreatorProfileCard(BuildContext context, List<Item> items) {
    return BackgroundForm(
      paddingVertical: 10,
      paddingHorizontal: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCreatorHeader(items),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: buildOffersList(widget.creator.offers, context, widget.creator),
          ),
          _buildRatingSection(),
          const SizedBox(height: 10),
          const Divider(thickness: 0.5),
          const SizedBox(height: 10),
          _buildCreatorInfoGrid(),
        ],
      ),
    );
  }

  Widget _buildCreatorHeader(List<Item> items) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: items.isNotEmpty ? items[0].creatorImage : '',
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.store, size: 48),
          ),
        ),
        const SizedBox(width: 20),
        Text(
          widget.creator.storeName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return RatingWidget(
      userId: CacheHelper.getData(key: 'userIdTwo'),
      creatorId: widget.creator.id,
      initialRating: widget.creator.rate ?? 0.0,
      reviewCount: widget.creator.rateCount ?? 0,
    );
  }

  Widget _buildCreatorInfoGrid() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              const Icon(IconBroken.Location),
              const SizedBox(height: 10),
              Text("location".tr()),
              Text('${widget.creator.address?.city}', style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              const Icon(IconBroken.Time_Circle),
              const SizedBox(height: 10),
              Text('${"closeAt".tr()}'),
              Text(
                widget.creator.availability.isNotEmpty
                    ? DateFormat("h:mm a").format(
                  DateFormat("HH:mm:ss").parse(widget.creator.availability[0].closeAt),
                )
                    : 'No close',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),

      ],
    );
  }

  Widget _buildItemsList(List<Item> items) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: () {
           Navigator.push(context, MaterialPageRoute(
               builder: (context)=> ProductDetailScreen(
                   itemId: item.id,
                    productDescription:item.description,
                    productName: item.name,
                    productPrice: item.price,
                    creator: widget.creator,
                    isAvailable: widget.isAvailable,
                    professionId: widget.professionID,
                     portfolioLink: item.freelancerPortfolioLinks,
                      syllabus: item.tutoringSyllabus ,
               )),
           );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
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
                      child: item.pictures.isNotEmpty
                          ? CachedNetworkImage(
                        imageUrl: item.pictures[0],
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                        const Center(child: Icon(Icons.image_not_supported)),
                      )
                          : const Center(child: Icon(Icons.image_not_supported)),
                    ),
                    // Positioned Widgets داخل Stack
                    if(widget.professionID==1 || widget.professionID==2 )
                    Positioned(
                      top: 10,
                      left: 10,
                      child: _buildBadge('${item.restaurantTime}'),
                    ),
                    if(widget.professionID==4)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: _buildBadge('${item.hcTime}'),
                    ),

                    Positioned(
                      top: 10,
                      left: widget.professionID!=3 && widget.professionID!=5 && widget.professionID!=6?  100 : 10,
                      child: _buildBadge('\$ ${item.price}'),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            if(widget.professionID==5)
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.work_history , color: textColor,),
                                    SizedBox(width: 5,),
                                    Text(
                                        'Work Time : ${item.freelancerWorkingTime}',
                                        style: TextStyle(color: textColor, fontWeight: FontWeight.bold , fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            if(widget.professionID==6)
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.watch_later_outlined, color: textColor,),
                                    SizedBox(width: 5,),
                                    Text(
                                        'Course Duration : ${item.tutoringCourseDuration}',
                                        style: TextStyle(color: textColor, fontWeight: FontWeight.bold , fontSize: 14),
                                    ),
                                  ],
                                ),
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  List<Widget> buildOffersList(List<CreatorOffer> offers, BuildContext context, CreatorItem creator) {
    List<Widget> widgets = [];

    bool hasFreeDelivery = offers.any((offer) => offer.type == 'free_delivery');
    if(widget.professionID !=5 && widget.professionID!=6) {
      if (!hasFreeDelivery) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Icon(Icons.local_shipping, color: textColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${'changeDelivery'.tr()} : ${creator.deliveryValue} \$',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
        );
      }
    }

    widgets.addAll(offers.map((offer) {
      String displayName;
      String valueText = '';
      String suffix = '';

      switch (offer.type) {
        case 'free_delivery':
          displayName = 'free_delivery'.tr();
          break;
        case 'first_order_discount':
          displayName = 'first_order_discount'.tr();
          suffix = '%';
          break;
        case 'all_orders_discount':
          displayName = 'all_orders_discount'.tr();
          suffix = '%';
          break;
        default:
          displayName = '';
      }

      if (offer.type != 'free_delivery') {
        int intValue = double.tryParse(offer.value)?.toInt() ?? 0;
        valueText = '$intValue$suffix';
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Icon(Icons.local_offer, color: Theme.of(context).primaryColor, size: 20),
            const SizedBox(width: 8),
            Row(
              children: [
                Text(
                  displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(width: 2),
                if (valueText.isNotEmpty)
                  Icon(Icons.arrow_forward, color: Theme.of(context).primaryColor),
              ],
            ),
            if (valueText.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  border: Border.all(color: textColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  valueText,
                  style: const TextStyle(color: Colors.teal, fontSize: 12),
                ),
              ),
          ],
        ),
      );
    }));

    return widgets;
  }
}
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/helper/user_data_manager.dart';
import '../../../../../core/theme/LocaleKeys.dart';
import '../../../../../core/theme/icons_broken.dart';
import '../../../../../data/models/advertisement_model.dart';
import 'SearchFilterScreen.dart';
import 'items_logic/items_get_cubit.dart';
import 'items_logic/items_git_states.dart';
import 'orders/cart/CartIconWithBadge.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> with WidgetsBindingObserver  {
  int selectedCategoryIndex = -1;
  List<Advertisement> _cachedAdvertisements = [];
  final List<Category> categories = [
    Category(id: 1, imagePath: 'assets/images/food.png',      title: LocaleKeys.food.tr()),
    Category(id: 2, imagePath: 'assets/images/sweet.png',     title: LocaleKeys.sweets.tr()),
    Category(id: 3, imagePath: 'assets/images/home.png',      title: LocaleKeys.homeServices.tr()),
    Category(id: 4, imagePath: 'assets/images/hand.png',      title: LocaleKeys.handCraft.tr()),
    Category(id: 5, imagePath: 'assets/images/freelance.png', title: LocaleKeys.freelancers.tr()),
    Category(id: 6, imagePath: 'assets/images/teach.png',     title: LocaleKeys.tutoring.tr()),
  ];

  final String noAdsPlaceholderImage = 'assets/images/no_ads_placeholder.png';


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<UserItemsCubit>().fetchActiveAdvertisements();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<UserItemsCubit>().fetchActiveAdvertisements();
    }
    super.didChangeAppLifecycleState(state);
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = UserDataManager.getUserModel();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Image(
              width: 200,
              image: AssetImage('assets/images/logo.png'),
            ),
            const SizedBox(height: 20),
            Container(
              height: 55,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(LocaleKeys.whereHome.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 5),
                        Text(LocaleKeys.talentMeetsYourNeeds.tr(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), maxLines: 1,),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      height: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Theme.of(context).primaryColor,
                      ),
                      child: Row(
                        children: [
                          Text(LocaleKeys.mashru3iPoints.tr(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Text('${user?.points}.0 Pts.', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            BlocBuilder<UserItemsCubit, UserItemsState>(
              builder: (context, state) {
                print('UserHomeScreen: BlocBuilder received state: $state');

                if (state is ActiveAdvertisementsLoadingState) {
                  print('UserHomeScreen: Displaying loading indicator.');
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                List<Advertisement> advertisements = [];

                if (state is ActiveAdvertisementsSuccessState) {
                  if (state.advertisements.isNotEmpty) {
                    advertisements = state.advertisements;
                    _cachedAdvertisements = state.advertisements;
                    print('UserHomeScreen: Displaying advertisements from API.');
                  } else {
                    _cachedAdvertisements = [];
                    print('UserHomeScreen: ActiveAdvertisementsSuccessState with EMPTY advertisements. Displaying placeholder.');
                    return _buildPlaceholderAdWidget();
                  }
                }
                else if (state is ActiveAdvertisementsErrorState) {
                  if (_cachedAdvertisements.isNotEmpty) {
                    print('UserHomeScreen: Error state but we have cached data, showing cached ads.');
                    advertisements = _cachedAdvertisements;
                  } else {
                    print('UserHomeScreen: Error state with NO cache, showing placeholder.');
                    return _buildPlaceholderAdWidget();
                  }
                }
                else {
                  if (_cachedAdvertisements.isNotEmpty) {
                    print('UserHomeScreen: Unknown state, showing cached advertisements.');
                    advertisements = _cachedAdvertisements;
                  } else {
                    print('UserHomeScreen: Unknown state with NO cache, showing placeholder.');
                    return _buildPlaceholderAdWidget();
                  }
                }

                return Container(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: CarouselSlider(
                    items: advertisements.map(
                          (ad) => GestureDetector(
                        onTap: () async {
                          if (ad.redirectUrl != null && ad.redirectUrl!.isNotEmpty) {
                            final Uri url = Uri.parse(ad.redirectUrl!);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(LocaleKeys.could_not_launch_url.tr())),
                              );
                            }
                          }
                        },
                        child: CachedNetworkImage(
                          imageUrl: ad.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) {
                            print('UserHomeScreen: Error loading image $url: $error');
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                  Text(LocaleKeys.image_load_error.tr(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ).toList(),
                    options: CarouselOptions(
                      height: 200.0,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 3),
                      autoPlayAnimationDuration: const Duration(seconds: 1),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      viewportFraction: 1.0,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),
            // ... (باقي الكود: Search bar, Cart icon, Categories GridView)
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context)=> SearchFilterScreen(
                      categoryTitle: LocaleKeys.searchAnything.tr(),
                      initialSearch: '',
                      initialMinRate:0,
                      initialFreeDelivery: true,
                      initialHasOffer: true,
                      initialIsOpenNow: true,
                    ),)
                );
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children:  [
                          const Icon(IconBroken.Search, color: Colors.grey),
                          const SizedBox(width: 10),
                          Text(LocaleKeys.searchAnything.tr(), style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadiusDirectional.only(
                          topEnd: Radius.circular(8),
                          bottomEnd: Radius.circular(8),
                        ),
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                      ),
                      child: const CartIconWithBadge(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategoryIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategoryIndex = index;
                      });
                      context.read<UserItemsCubit>().fetchCreatorByProfessionId(category.id);
                      context.push('/itemsByProfession/${category.id}', extra: category.title);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.greenAccent : Colors.grey.shade200,
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            category.imagePath,
                            width: 50,
                            height: 50,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            textAlign: TextAlign.center,
                            category.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderAdWidget() {
    return Container(
      height: 200,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[200],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              noAdsPlaceholderImage,
              width: 100,
              height: 100,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.info_outline, size: 50, color: Colors.grey);
              },
            ),
            const SizedBox(height: 10),
            Text(
              LocaleKeys.no_ads_available.tr(),
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class Category {
  final int id;
  final String imagePath;
  final String title;
  Category({required this.id, required this.imagePath, required this.title});
}
import 'dart:convert';
import 'dart:io';

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/cubit/language_cubit.dart';
import '../../../../../core/theme/LocaleKeys.dart';
import '../../../../../core/theme/icons_broken.dart';
import '../../../../widgets/compnents.dart';
import '../../../../widgets/coustem_form_input.dart';
import '../../../../widgets/custom_button.dart';
import '../../add_items_screen/widgets/images.dart';
import '../logic/dashboard_cibit.dart';
import '../logic/dashboard_states.dart';
import '../logic/delivary_charge.dart';
import '../logic/wedgit.dart';

class DashBoardProfileScreen extends StatefulWidget {
  const DashBoardProfileScreen({super.key});

  @override
  State<DashBoardProfileScreen> createState() => _DashBoardProfileScreenState();
}

class _DashBoardProfileScreenState extends State<DashBoardProfileScreen> {
  TextEditingController storeController = TextEditingController();
  TextEditingController deliveryController = TextEditingController();
  double deliveryCharge = 3.0;
  late FToast fToast;

  // Notification states
  bool showAddressBadge = false;
  bool showAvailabilityBadge = false;
  bool showPromotionsBadge = false;
  bool showPaymentBadge = false;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    final cubit = BlocProvider.of<DashBoardCubit>(context);
    cubit.getProfileData();
    storeController.text = cubit.creatorProfile?.storeName ?? '';
    _loadNotificationStates();
  }

  Future<void> _loadNotificationStates() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      showAddressBadge = prefs.getBool('address_seen') != true;
      showAvailabilityBadge = prefs.getBool('availability_seen') != true;
      showPromotionsBadge = prefs.getBool('promotions_seen') != true;
      showPaymentBadge = prefs.getBool('payment_seen') != true;
    });
  }

  Future<void> _markAsSeen(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, true);
    setState(() {
      if (key == 'address_seen') showAddressBadge = false;
      if (key == 'availability_seen') showAvailabilityBadge = false;
      if (key == 'promotions_seen') showPromotionsBadge = false;
      if (key == 'payment_seen') showPaymentBadge = false;
    });
  }

  @override
  void dispose() {
    fToast.removeCustomToast();
    super.dispose();
  }

  String getProfessionName(int? id) {
    switch (id) {
      case 1:
        return 'Food';
      case 2:
        return 'Sweet';
      case 3:
        return 'More Services';
      case 4:
        return 'Hand Crafter';
      case 5:
        return 'Freelancer\'s';
      case 6:
        return 'Tutoring';
      default:
        return 'Unknown';
    }
  }

  void _showSuccessToast(String message) {
    fToast.showToast(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Theme.of(context).primaryColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check, color: Colors.black),
            const SizedBox(width: 12.0),
            Text(message, style: const TextStyle(color: Colors.black)),
          ],
        ),
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 5),
    );
  }

  void _showErrorToast(String message) {
    fToast.showToast(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Colors.red,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12.0),
            Text(message, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 3),
    );
  }

  Future<void> _showConfirmationDialog(BuildContext context, String title, String content, VoidCallback onConfirm) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text(LocaleKeys.cancel.tr(), style: TextStyle(color: Colors.red[900])),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(LocaleKeys.confirm.tr(), style: TextStyle(color: Colors.green[900])),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.grey[700],
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildInfoContainer(String text) {
    return Container(
      padding: const EdgeInsets.all(15),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
        color: Colors.grey[100],
      ),
      child: Row(
        children: [
          Icon(Icons.work_outline_sharp, color: Colors.grey),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.grey[700]),
              const SizedBox(width: 10),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonWithBadge({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    required String badgeKey,
    required bool showBadge,
    IconData? icon,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildActionButton(
          context: context,
          text: text,
          onPressed: () {
            _markAsSeen(badgeKey);
            onPressed();
          },
          icon: icon,
        ),
        if (showBadge)
          Positioned(
            right: 10,
            top: -5,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 12,
                minHeight: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _showConfirmationDialog(
            context,
            LocaleKeys.logoutConfirmation.tr(),
            LocaleKeys.areYouSureLogout.tr(),
                () => context.read<DashBoardCubit>().logout(),
          );
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Theme.of(context).primaryColor,
          backgroundColor: Colors.black26,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout),
            const SizedBox(width: 10),
            Text(
              'LOGOUT',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashBoardCubit, DashBoardStates>(
      listener: (context, state) {
        if (state is UpdateDeliveryValueSuccess) {
          _showSuccessToast("Delivery value updated successfully");
          setState(() {
            deliveryCharge = state.newValue;
          });
        }
        if (state is UpdateStoreNameLoaded) {
          _showSuccessToast(LocaleKeys.storeNameChangedSuccessfully.tr());
        } else if (state is UpdateStoreNameError) {
          _showErrorToast(LocaleKeys.notEnoughBalance.tr());
        } else if (state is ProfileError) {
          _showErrorToast(LocaleKeys.profileLoadError.tr());
        }
        if (state is LoggedOutState) {
          context.go('/choose');
        } else if (state is LogoutErrorState) {
          _showErrorToast(state.message);
        }
      },
      builder: (context, state) {
        final cubit = context.read<DashBoardCubit>();
        final profile = cubit.creatorProfile;
        if (profile == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final professionName = getProfessionName(profile.professionId);
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 100),
                          child: BackgroundForm(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 60, bottom: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Profession Section
                                  _buildSectionTitle(LocaleKeys.profession.tr()),
                                  const SizedBox(height: 8),
                                  _buildInfoContainer(professionName),
                                  const SizedBox(height: 20),
                                  // Store Name Section
                                  _buildSectionTitle(LocaleKeys.editStoreName.tr()),
                                  const SizedBox(height: 8),
                                  ChangeStoreName(context, cubit, storeController),
                                  const SizedBox(height: 20),

                                  // Delivery Charge Section
                                  _buildSectionTitle(LocaleKeys.changeDelivery.tr()),
                                  const SizedBox(height: 8),
                                  ChangeDelivery(context, cubit, deliveryController, deliveryCharge),
                                  const SizedBox(height: 30),

                                  // Action Buttons
                                  _buildActionButton(
                                    context: context,
                                    text: LocaleKeys.wallet.tr(),
                                    onPressed: () => context.push('/WalletScreen'),
                                  ),
                                  const SizedBox(height: 15),

                                  _buildActionButtonWithBadge(
                                    context: context,
                                    text: LocaleKeys.address.tr(),
                                    badgeKey: 'address_seen',
                                    showBadge: showAddressBadge,
                                    onPressed: () => context.push('/AddressForm'),
                                  ),
                                  const SizedBox(height: 15),

                                  _buildActionButtonWithBadge(
                                    context: context,
                                    text: LocaleKeys.promotions.tr(),
                                    badgeKey: 'promotions_seen',
                                    showBadge: showPromotionsBadge,
                                    onPressed: () => context.push('/OffersScreen'),
                                  ),
                                  const SizedBox(height: 15),

                                  _buildActionButtonWithBadge(
                                    context: context,
                                    text: LocaleKeys.availability.tr(),
                                    badgeKey: 'availability_seen',
                                    showBadge: showAvailabilityBadge,
                                    onPressed: () => context.push('/AvailabilityScreen'),
                                  ),
                                  const SizedBox(height: 15),

                                  _buildActionButtonWithBadge(
                                    context: context,
                                    text: LocaleKeys.paymentsGateway.tr(),
                                    badgeKey: 'payment_seen',
                                    showBadge: showPaymentBadge,
                                    onPressed: () => context.push('/PaymentMethodsScreen'),
                                  ),
                                  const SizedBox(height: 15),

                                  _buildActionButton(
                                    context: context,
                                    text: context.locale.languageCode == 'en' ? 'العربية' : 'English',
                                    icon: Icons.language,
                                    onPressed: () {
                                      final newLocale = context.locale.languageCode == 'en'
                                          ? const Locale('ar')
                                          : const Locale('en');
                                      context.read<LanguageCubit>().changeLanguage(newLocale, context);
                                    },
                                  ),
                                  const SizedBox(height: 15),

                                  ConditionalBuilder(
                                    condition: state is! LogoutLoadingState,
                                    builder: (context) => _buildLogoutButton(context),
                                    fallback: (context) => Center(
                                      child: CircularProgressIndicator(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        ProfileImagesWidget(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
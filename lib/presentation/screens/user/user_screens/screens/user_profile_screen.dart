import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;

import '../../../../../core/cubit/language_cubit.dart';
import '../../../../../core/helper/user_data_manager.dart';
import '../../../../../core/theme/LocaleKeys.dart';
import '../../../../../core/theme/color.dart';
import '../../../../../core/theme/icons_broken.dart';
import '../../../../widgets/compnents.dart';
import '../../../creator/dashboard_screen/logic/dashboard_cibit.dart';
import '../../../../notification/Notifications .cubit.dart';
import '../../../../notification/Notifications .states.dart';
import '../profile_screens/ui/NotificationsScreen.dart';
import '../profile_screens/ui/change_password_screen.dart';
import '../profile_screens/ui/termsAndConditionsScreen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    context.read<NotificationsCubit>().fetchNotifications(userType: 'user');
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<NotificationsCubit>().fetchNotifications(userType: 'user');
    }
  }

  Future<void> _showConfirmationDialog(
      BuildContext context,
      String title,
      String content,
      VoidCallback onConfirm
      ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(fontSize: 18),),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text(LocaleKeys.cancel.tr() , style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(LocaleKeys.confirm.tr(),  style: TextStyle(color:textColor, fontWeight: FontWeight.bold),),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          withNav(context),
          Positioned.fill(
            top: 35,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildProfileContent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: BackgroundForm(
        key: ValueKey(context.locale.languageCode),
        paddingHorizontal: 10,
        paddingVertical: 10,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 16),
              _buildMenuItems(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final user = UserDataManager.getUserModel();
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Theme.of(context).primaryColor,

                ),
                shape: BoxShape.circle
              ),
              child: const CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage('assets/images/icon-m.png'),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${user?.firstName}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 5,),
                    Text(
                      '${user?.lastName}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 5,),
                    Icon(
                      Icons.verified_sharp,
                      color:Colors.green,
                      size: 18,
                    ),
                  ],
                ),
                Text(
                  '${user?.email}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Column(
      key: ValueKey(context.locale.languageCode),
      children: [
        _buildMenuItem(
          context,
          icon: IconBroken.User,
          titleKey: LocaleKeys.personalInfo.tr(),
          onTap: () {
            context.push('/PersonalInfoScreen');
          },
        ),
        _buildNotificationMenuItem(context),
        _buildMenuItem(
          context,
          icon: IconBroken.Location,
          titleKey: LocaleKeys.myAddresses.tr(),
          onTap: () => context.push('/AddressScreen'),
        ),
        _buildMenuItem(
            context,
            icon: IconBroken.Lock,
            titleKey: LocaleKeys.changePassword.tr(),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>ChangePasswordScreen()));
            }

        ),
        _buildMenuItem(
          context,
          icon: Icons.translate,
          titleKey: 'language',
          onTap: () {
            _showLanguageDialog(context);
          },
        ),
        _buildMenuItem(
          context,
          icon: IconBroken.Info_Circle,
          titleKey: LocaleKeys.termsAndConditions.tr(),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>TermsAndConditionsScreen()));
          },
        ),
        _buildMenuItem(
          context,
          icon: Icons.privacy_tip_outlined,
          titleKey: LocaleKeys.privacyPolicy.tr(),
          onTap: () {
            context.push('/PrivacyPolicyScreen');
          },
        ),
        const SizedBox(height: 8),
        _buildLogoutButton(context),
      ],
    );
  }

  Widget _buildNotificationMenuItem(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        int unreadCount = 0;
        if (state is NotificationsLoaded) {
          unreadCount = state.notifications.where((n) => !n.isRead).length;
        }
        return Card(
          color: Theme.of(context).primaryColor.withOpacity(0.15),
          key: ValueKey(LocaleKeys.notification.tr() + context.locale.languageCode),
          margin: const EdgeInsets.symmetric(vertical: 3),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: badges.Badge(
              showBadge: unreadCount > 0,
              badgeContent: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              badgeStyle: const badges.BadgeStyle(
                padding: EdgeInsets.all(6),
                badgeColor: Colors.red,
              ),
              position: badges.BadgePosition.topEnd(top: -5, end: -5),
              child: Icon(IconBroken.Notification, color: textColor),
            ),
            title: Text(
              LocaleKeys.notification.tr(),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>NotificationsScreen(
                userType: 'user',
              )));
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required String titleKey,
        VoidCallback? onTap,
      }) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Card(
        color: Theme.of(context).primaryColor.withOpacity(0.15),
        key: ValueKey(titleKey + context.locale.languageCode),
        margin: const EdgeInsets.symmetric(vertical: 3),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: Icon(icon, color:textColor),
          title: Text(
            titleKey.tr(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Card(
        key: ValueKey('logout' + context.locale.languageCode),
        margin: const EdgeInsets.symmetric(vertical: 4),
        elevation: 0,
        color: Colors.red.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: Icon(Icons.logout, color: Colors.red[700]),
          title: Text(
            LocaleKeys.logout.tr(),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.red[700],
            ),
          ),
          onTap: () {
            _showConfirmationDialog(
              context,
              LocaleKeys.logoutConfirmation.tr(),
              LocaleKeys.areYouSureLogout.tr(),
                  () {
                context.read<DashBoardCubit>().logout();
                context.go('/choose');
              },
            );
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Container(
            key: ValueKey(context.locale.languageCode),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'select_language'.tr(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 20),
                _buildLanguageOption(
                  context,
                  languageCode: 'en',
                  languageName: 'English',
                  flag: '🇬🇧',
                  isSelected: context.locale.languageCode == 'en',
                ),
                const SizedBox(height: 12),
                _buildLanguageOption(
                  context,
                  languageCode: 'ar',
                  languageName: 'العربية',
                  flag: '🇱🇧',
                  isSelected: context.locale.languageCode == 'ar',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
      BuildContext context, {
        required String languageCode,
        required String languageName,
        required String flag,
        required bool isSelected,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () async {
          await HapticFeedback.lightImpact();
          final newLocale = Locale(languageCode);
          await context.read<LanguageCubit>().changeLanguage(newLocale, context);
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 16),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    languageName,
                    key: ValueKey(languageCode),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
            ],
          ),
        ),
      ),
    );
  }
}

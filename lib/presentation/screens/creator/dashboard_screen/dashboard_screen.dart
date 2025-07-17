import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mashrou3i/core/theme/color.dart';
import 'package:mashrou3i/presentation/screens/creator/dashboard_screen/screens/dash_board_home_screen.dart';
import 'package:mashrou3i/presentation/screens/creator/dashboard_screen/screens/dash_board_income_screen.dart';
import 'package:mashrou3i/presentation/screens/creator/dashboard_screen/screens/dash_board_notification_screen.dart';
import 'package:mashrou3i/presentation/screens/creator/dashboard_screen/screens/dash_board_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:badges/badges.dart' as badges; // 💡 Import the badges package

import '../../../../core/theme/LocaleKeys.dart';
import '../../../../core/theme/icons_broken.dart';
import '../../../notification/Notifications .cubit.dart';
import '../../../notification/Notifications .states.dart';
import '../add_items_screen/cubit/get_item_cubit.dart';
import 'logic/dashboard_cibit.dart';
import 'logic/dashboard_states.dart';

class DashBoardScreen extends StatefulWidget {
  @override
  _DashBoardScreenState createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  final List<Widget> dashboardScreens = [
    DashBoardHomeScreen(),
    DashBoardIncomeScreen(),
    DashBoardNotificationScreen(userType: 'creator'),
    DashBoardProfileScreen(),
  ];

  bool showProfileBadge = false;

  @override
  void initState() {
    super.initState();
    _loadProfileBadgeState();
    context.read<NotificationsCubit>().fetchNotifications(userType: 'creator');
  }

  Future<void> _loadProfileBadgeState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      showProfileBadge = prefs.getBool('profile_badge_seen') != true;
    });
  }

  Future<void> _markProfileBadgeAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('profile_badge_seen', true);
    setState(() {
      showProfileBadge = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashBoardCubit, DashBoardStates>(
      listener: (context, state) {},
      builder: (context, state) {
        final cubit = DashBoardCubit.get(context);
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          bottomNavigationBar: _buildBottomNavBar(context, cubit),
          body: _buildCurrentScreen(cubit, context),
        );
      },
    );
  }

  Widget _buildBottomNavBar(BuildContext context, DashBoardCubit cubit) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: cubit.dashboardCurrentIndex,
          onTap: (index) {
            if (index == 3) {
              _markProfileBadgeAsSeen();
            }
            cubit.dashboardChangeBottom(index);
          },
          backgroundColor: Theme.of(context).cardColor,
          selectedItemColor: textColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          elevation: 10,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: cubit.dashboardCurrentIndex == 0
                      ? Theme.of(context).primaryColor.withOpacity(0.2)
                      : Colors.transparent,
                ),
                child: Icon(IconBroken.Home, size: 24),
              ),
              label: LocaleKeys.home.tr(),
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: cubit.dashboardCurrentIndex == 1
                      ? Theme.of(context).primaryColor.withOpacity(0.2)
                      : Colors.transparent,
                ),
                child: Icon(Icons.monetization_on, size: 24),
              ),
              label: LocaleKeys.income.tr(),
            ),
            BottomNavigationBarItem(
              icon: BlocBuilder<NotificationsCubit, NotificationsState>(
                builder: (context, state) {
                  int unreadCount = 0;
                  if (state is NotificationsLoaded) {
                    unreadCount = state.notifications.where((n) => !n.isRead).length;
                  }
                  return badges.Badge(
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
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: cubit.dashboardCurrentIndex == 2
                            ? Theme.of(context).primaryColor.withOpacity(0.2)
                            : Colors.transparent,
                      ),
                      child: Icon(IconBroken.Notification, size: 24),
                    ),
                  );
                },
              ),
              label: LocaleKeys.notification.tr(),
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: cubit.dashboardCurrentIndex == 3
                          ? Theme.of(context).primaryColor.withOpacity(0.2)
                          : Colors.transparent,
                    ),
                    child: Icon(IconBroken.Profile, size: 24),
                  ),
                  if (showProfileBadge)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).cardColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              label: LocaleKeys.profile.tr(),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildCurrentScreen(DashBoardCubit cubit, context) {
    return dashboardScreens[cubit.dashboardCurrentIndex];
  }
}
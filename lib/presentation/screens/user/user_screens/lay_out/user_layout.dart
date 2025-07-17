import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:badges/badges.dart' as badges;

import '../../../../../core/theme/LocaleKeys.dart';
import '../../../../../core/theme/color.dart';
import '../../../../../core/theme/icons_broken.dart';
import '../../../../notification/Notifications .cubit.dart';
import '../../../../notification/Notifications .states.dart';
import '../user_cubit/user_cubit.dart';
import '../user_cubit/user_states.dart';

class UserLayout extends StatefulWidget {
  const UserLayout({super.key});

  @override
  State<UserLayout> createState() => _UserLayoutState();
}

class _UserLayoutState extends State<UserLayout> with WidgetsBindingObserver {
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) {
        return UserCubit();
      },
      child: BlocBuilder<UserCubit , UserStates>(
        builder: (context , state){
          UserCubit cubit = UserCubit.get(context);
          return Scaffold(
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: BottomNavigationBar(
                  currentIndex: cubit.currentIndex,
                  onTap: (index) => cubit.changeBottom(index),
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  selectedItemColor: textColor,
                  unselectedItemColor: Colors.grey,
                  selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  elevation: 10,
                  items: [
                    BottomNavigationBarItem(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: cubit.currentIndex == 0
                              ? Theme.of(context).primaryColor.withOpacity(0.1)
                              : Colors.transparent,
                        ),
                        child: const Icon(IconBroken.Home, size: 26),
                      ),
                      label: LocaleKeys.home.tr(),
                    ),
                    BottomNavigationBarItem(
                      icon: BlocBuilder<NotificationsCubit, NotificationsState>(
                        builder: (context, state) {
                          int orderNotificationCount = 0;
                          if (state is NotificationsLoaded) {
                            orderNotificationCount = state.notifications.where((n) =>
                            !n.isRead &&
                                (n.data?['type'] == 'order_accepted' ||
                                    n.data?['type'] == 'order_canceled')
                            ).length;
                          }
                          return badges.Badge(
                            showBadge: orderNotificationCount > 0,
                            badgeContent: Text(
                              orderNotificationCount > 99 ? '99+' : orderNotificationCount.toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                            ),
                            badgeStyle: const badges.BadgeStyle(
                              padding: EdgeInsets.all(6),
                              badgeColor: Colors.red,
                            ),
                            position: badges.BadgePosition.topEnd(top: -5, end: -5),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: cubit.currentIndex == 1
                                    ? Theme.of(context).primaryColor.withOpacity(0.2)
                                    : Colors.transparent,
                              ),
                              child: const Icon(IconBroken.Document, size: 26),
                            ),
                          );
                        },
                      ),
                      label: LocaleKeys.orders.tr(),
                    ),
                    BottomNavigationBarItem(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: cubit.currentIndex == 2
                              ? Theme.of(context).primaryColor.withOpacity(0.2)
                              : Colors.transparent,
                        ),
                        child: const Icon(IconBroken.Info_Circle, size: 26),
                      ),
                      label: LocaleKeys.help.tr(),
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
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: cubit.currentIndex == 3
                                    ? Theme.of(context).primaryColor.withOpacity(0.2)
                                    : Colors.transparent,
                              ),
                              child: const Icon(IconBroken.Profile, size: 26),
                            ),
                          );
                        },
                      ),
                      label: LocaleKeys.profile.tr(),
                    ),
                  ],
                ),
              ),
            ),
            body: cubit.bottomScreens[cubit.currentIndex],
          );
        },
      ),
    );
  }
}
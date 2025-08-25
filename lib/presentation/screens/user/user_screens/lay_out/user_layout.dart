import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:badges/badges.dart' as badges;
import 'package:go_router/go_router.dart';

import '../../../../../core/network/local/cach_helper.dart';
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
  late bool isGuest;

  @override
  void initState() {
    super.initState();
    // إشعارات فقط للمستخدم المسجّل
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    final extraGuest = (extra is Map && extra['guest'] == true);
    isGuest = extraGuest || (CacheHelper.getData(key: 'guest') == true);

    if (!isGuest) {
      // مستخدم مسجّل
      context.read<NotificationsCubit>().fetchNotifications(userType: 'user');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !isGuest) {
      context.read<NotificationsCubit>().fetchNotifications(userType: 'user');
    }
  }

  void _showLoginRequiredSheet() {
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


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserCubit(),
      child: BlocBuilder<UserCubit, UserStates>(
        builder: (context, state) {
          final cubit = UserCubit.get(context);
          return Scaffold(
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: BottomNavigationBar(
                  currentIndex: cubit.currentIndex,
                  onTap: (index) {
                    if (isGuest && index != 0) {
                      _showLoginRequiredSheet();
                      return;
                    }
                    cubit.changeBottom(index);
                  },
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  selectedItemColor: textColor,
                  unselectedItemColor: Colors.grey,
                  selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  elevation: 10,
                  items: [
                    const BottomNavigationBarItem(
                      icon: _NavIcon(index: 0, child: Icon(IconBroken.Home, size: 26)),
                      label: 'Home',
                    ),
                    const BottomNavigationBarItem(
                      icon: _NavIcon(index: 1, child: Icon(IconBroken.Document, size: 26)),
                      label: 'Orders',
                    ),
                    const BottomNavigationBarItem(
                      icon: _NavIcon(index: 2, child: Icon(IconBroken.Info_Circle, size: 26)),
                      label: 'Help',
                    ),
                    const BottomNavigationBarItem(
                      icon: _NavIcon(index: 3, child: Icon(IconBroken.Profile, size: 26)),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
            // 👇 السلوك: لو ضيف واخترت تبويب غير الـ Home، بنظل نعرض الـ Home
            body: isGuest ? cubit.bottomScreens[0] : cubit.bottomScreens[cubit.currentIndex],
          );
        },
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final int index;
  final Widget child;
  const _NavIcon({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    final cubit = UserCubit.get(context);
    final selected = cubit.currentIndex == index;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: selected ? Theme.of(context).primaryColor.withOpacity(0.2) : Colors.transparent,
      ),
      child: child,
    );
  }
}

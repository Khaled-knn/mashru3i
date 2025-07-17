import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/network/local/cach_helper.dart';
import '../screens/choose_role_language_screen.dart';
import '../screens/creator/add_items_screen/add_items.dart';
import '../screens/creator/dashboard_screen/craetor_address/AddressForm.dart';
import '../screens/creator/dashboard_screen/dashboard_screen.dart';
import '../screens/creator/dashboard_screen/logic/dashboard_cibit.dart'; // استورد الـ Cubit
import '../screens/creator/dashboard_screen/offers/offers_screen.dart';
import '../screens/creator/dashboard_screen/payment_mehods/payment_methods_screen.dart';
import '../screens/creator/dashboard_screen/screens/orders_screen.dart';
import '../screens/creator/dashboard_screen/screens/recent_items.dart';
import '../screens/creator/dashboard_screen/screens/wallet_screen.dart';
import '../screens/creator/login/ui/creator_login_screen.dart';
import '../screens/creator/register/ui/creator_register.dart';
import '../screens/on_bording.dart';
import '../screens/pendingApprovalScreen.dart';
import '../screens/splash_screen.dart';
import '../screens/user/log_in/ui/forget_password.dart';
import '../screens/user/log_in/ui/user_login.dart';
import '../screens/user/register/ui/user_register_screen.dart';
import '../screens/user/user_screens/lay_out/user_layout.dart';
import '../screens/user/user_screens/profile_screens/ui/address_screen.dart';
import '../screens/user/user_screens/profile_screens/ui/change_password_screen.dart';
import '../screens/user/user_screens/profile_screens/ui/policyscreen.dart';
import '../screens/user/user_screens/profile_screens/ui/presonal_info.dart';
import '../screens/user/user_screens/profile_screens/ui/termsAndConditionsScreen.dart';
import '../screens/user/user_screens/screens/ProductDetailScreen.dart';
import '../screens/user/user_screens/screens/items_by_profession_screen.dart';
import '../screens/user/user_screens/screens/items_logic/items_by_creatorId_screen.dart';
import '../screens/user/user_screens/screens/items_logic/items_get_cubit.dart';
import '../screens/user/user_screens/screens/orders/cart/cart_screen.dart';
import '../screens/user/user_screens/screens/orders/confirmed_order.dart';
import '../widgets/calander.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const onBoarding(),
      ),
      GoRoute(
        path: '/choose',
        builder: (context, state) => const ChoseScreen(),
      ),
      GoRoute(
        path: '/creatorRegister',
        builder: (context, state) => const CreatorRegister(),
      ),
      GoRoute(
        path: '/CreatorLoginScreen',
        builder: (context, state) => const CreatorLoginScreen(),
      ),
      GoRoute(
        path: '/AvailabilityScreen',
        builder: (context, state) =>  AvailabilityScreen(),
      ),
      GoRoute(
        path: '/DashBoardScreen',
        builder: (context, state) {
          return BlocProvider(
            create: (context) => DashBoardCubit(),
            child: DashBoardScreen(),
          );
        },
      ),
      GoRoute(
        path: '/PendingApprovalScreen',
        builder: (context, state) => PendingApprovalScreen(),
      ),
      GoRoute(
        path: '/AddItemsScreen',
        builder: (context, state) {
          return const AddItemScreen( );
        },
      ),
      GoRoute(
        path: '/UserLogin',
        builder: (context, state) {
          return const UserLogin( );
        },
      ),
      GoRoute(
        path: '/ForgetPassword',
        builder: (context, state) {
          return  ForgetPassword( );
        },
      ),
      GoRoute(
        path: '/UserRegisterScreen',
        builder: (context, state) {
          return  UserRegisterScreen( );
        },
      ),
      GoRoute(
        path: '/UserLayout',
        builder: (context, state) {
          return  UserLayout();
        },
      ),
      GoRoute(
        path: '/OrdersScreen',
        builder: (context, state) {
          return  OrdersScreen();
        },
      ),
      GoRoute(
        path: '/WalletScreen',
        builder: (context, state) {
          return  WalletScreen();
        },
      ),
      GoRoute(
        path: '/itemsByProfession/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          final title = state.extra as String; // إذا كنت تحتاج العنوان أيضًا
          return ItemsByProfessionScreen(
            professionId: id,
            title: title,
          );
        },
      ),
      GoRoute(
        path: '/RecentItems',
        builder: (context, state) {
          return  RecentItems();
        },
      ),
      GoRoute(
        path: '/CartScreen',
        builder: (context, state) {
          return  CartScreen();
        },
      ),
      GoRoute(
        path: '/AddressForm',
        builder: (context, state) {
          print("route ${CacheHelper.getData(key: "userId")}");
          return  AddressForm(
            creatorId: CacheHelper.getData(key: "userId"),
            token: CacheHelper.getData(key: "token"),
          );
        },
      ),
      GoRoute(
        path: '/AddressScreen',
        builder: (context, state) {
          return  AddressScreen();
        },
      ),
      GoRoute(
        path: '/ConfirmedOrder',
        builder: (context, state) {
          return  ConfirmedOrder();
        },
      ),
      GoRoute(
        path: '/PaymentMethodsScreen',
        builder: (context, state) {
          return  PaymentMethodsScreen();
        },
      ),
      GoRoute(
        path: '/OffersScreen',
        builder: (context, state) {
          return  OffersScreen();
        },
      ),
      GoRoute(
        path: '/PersonalInfoScreen',
        builder: (context, state) {
          return  PersonalInfoScreen();
        },
      ),
      GoRoute(
        path: '/PrivacyPolicyScreen',
        builder: (context, state) {
          return  PrivacyPolicyScreen();
        },
      ),
      GoRoute(
        path: '/TermsAndConditionsScreen ',
        builder: (context, state) {
          return  TermsAndConditionsScreen();
        },
      ),
      GoRoute(
        path: '/ChangePasswordScreen ',
        builder: (context, state) {
          return  ChangePasswordScreen();
        },
      ),
    ],
  );
}
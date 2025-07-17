import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mashrou3i/presentation/notification/Notifications%20.cubit.dart';
import 'package:mashrou3i/presentation/profession/logic/profession_cubit.dart';
import 'package:mashrou3i/presentation/screens/creator/add_items_screen/cubit/get_item_cubit.dart';
import 'package:mashrou3i/presentation/screens/creator/dashboard_screen/availability/availability_cubit.dart';
import 'package:mashrou3i/presentation/screens/creator/dashboard_screen/craetor_address/address_cubit.dart';
import 'package:mashrou3i/presentation/screens/creator/dashboard_screen/logic/dashboard_cibit.dart';
import 'package:mashrou3i/presentation/screens/creator/dashboard_screen/offers/offers_cubit.dart';
import 'package:mashrou3i/presentation/screens/creator/dashboard_screen/payment_mehods/payment_mehods_cubit.dart';
import 'package:mashrou3i/presentation/screens/creator/order/order_cubit.dart';
import 'package:mashrou3i/presentation/screens/creator/order/order_repo.dart';
import 'package:mashrou3i/presentation/screens/user/log_in/logic/user_cibit.dart';
import 'package:mashrou3i/presentation/screens/user/user_screens/profile_screens/logic/address_cubit.dart';
import 'package:mashrou3i/presentation/screens/user/user_screens/screens/favorites/FavoritesCubit.dart';
import 'package:mashrou3i/presentation/screens/user/user_screens/screens/items_logic/items_get_cubit.dart';
import 'package:mashrou3i/presentation/screens/user/user_screens/screens/orders/cart/CartCubit.dart';
import 'package:mashrou3i/presentation/screens/user/user_screens/screens/orders/user_order_cubit.dart';
import 'package:mashrou3i/presentation/screens/user/user_screens/screens/orders/user_order_repository.dart';
import 'app.dart';
import 'core/cubit/language_cubit.dart';
import 'core/cubit/observer/observer.dart';
import 'core/network/local/cach_helper.dart';
import 'core/network/remote/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
  print('onDidReceiveNotificationResponse (foreground): ${notificationResponse.payload}');
  if (notificationResponse.payload != null) {
  }
}

@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(NotificationResponse notificationResponse) async {
  print('onDidReceiveBackgroundNotificationResponse (background): ${notificationResponse.payload}');
  if (notificationResponse.payload != null) {
  }
}

Future<void> initLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    onDidReceiveBackgroundNotificationResponse: onDidReceiveBackgroundNotificationResponse,
  );
}

Future<void> showLocalNotification(RemoteMessage message) async {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  if (notification != null && android != null) {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformDetails,
      payload: message.data['payload'] ?? '',
    );
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initLocalNotifications();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print('🔐 صلاحيات الإشعارات: ${settings.authorizationStatus}');

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received foreground message: ${message.messageId}');
    if (message.notification != null) {
      print('Notification title: ${message.notification!.title}');
      print('Notification body: ${message.notification!.body}');
      showLocalNotification(message);
    }
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print('Received foreground message: ${message.messageId}');

    String? currentUserType = CacheHelper.getData(key: 'userType');
    String? notificationUserType = message.data['userType'];

    print('🔍 currentUserType: $currentUserType');
    print('🔍 notificationUserType: $notificationUserType');

    if (notificationUserType != null && currentUserType == notificationUserType) {
      if (message.notification != null) {
        print('Notification title: ${message.notification!.title}');
        print('Notification body: ${message.notification!.body}');
        await showLocalNotification(message);
      }
    } else {
      print('Ignored notification for userType mismatch.');
    }
  });


  Bloc.observer = MyBlocObserver();
  await CacheHelper.init();
  DioHelper.init();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.grey[100],
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/lang',
      fallbackLocale: const Locale('en'),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => LanguageCubit()),
          BlocProvider(create: (context) => FavoriteCubit()),

          BlocProvider(create: (context) => ProfessionCubit()..getProfessions()),
          BlocProvider(create: (context) => DashBoardCubit()..getProfileData()),
          BlocProvider(create: (context) => GetItemsCubit()..fetchMyItems()),
          BlocProvider(create: (context) => UserItemsCubit()),
          BlocProvider(create: (context) => CartCubit(dio: DioHelper.dio)),
          BlocProvider(create: (context) => AvailabilityCubit()),
          BlocProvider(create: (context) => PaymentMethodsCubit()),
          BlocProvider(create: (context) => OffersCubit()),
          BlocProvider(create: (context) => LoginCubit()),
          BlocProvider(create: (context) => UserOrdersCubit( UserOrderRepository(),)..fetchUserOrders()),
          BlocProvider(create: (context) => CreatorOrderCubit(
            CreatorOrderRepository(),
          )),
          BlocProvider(create: (context) => UserAddressCubit()),
          BlocProvider(create: (context) => NotificationsCubit()),
          BlocProvider(
            create: (context) => AddressCubit(
              creatorId: CacheHelper.getData(key: "userId"),
              token: CacheHelper.getData(key: "token"),
            ),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}
  
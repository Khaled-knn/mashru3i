import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/theme/app_theme.dart';
import 'presentation/routes/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});



  @override
  Widget build(BuildContext context) {

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      theme: AppTheme.themeByLocale(context.locale),
      darkTheme: AppTheme.themeByLocale(context.locale, isDark: true),
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.router,

    );

  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static ThemeData themeByLocale(Locale locale, {bool isDark = false}) {
    final fontFamily = locale.languageCode == 'ar' ? 'Cairo' : 'Poppins';
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor:Color.fromRGBO(242, 246, 247, 1) ,
      statusBarIconBrightness: Brightness.dark,
    ));
    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromRGBO(119, 247, 211, 1),
        primary: const Color.fromRGBO(119, 247, 211, 1),
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      scaffoldBackgroundColor:
      isDark ? const Color(0xFF121212) : const Color.fromRGBO(242, 246, 247, 1),
      textTheme: const TextTheme(
        titleSmall: TextStyle(fontSize: 15 , fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        labelLarge: TextStyle(fontSize: 16),
        bodySmall: TextStyle(fontSize: 12 , color: Colors.grey),
        titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),

      ),
      useMaterial3: true,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('App loads and shows welcome text', (WidgetTester tester) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/lang',
        fallbackLocale: const Locale('en'),
        child: const MyApp(
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Welcome to NextGen!'), findsOneWidget);
  });
}

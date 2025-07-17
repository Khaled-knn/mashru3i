import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('welcome'.tr())),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('hello'.tr(), style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.setLocale(Locale('ar'));
              },
              child: const Text("عربي"),
            ),
            ElevatedButton(
              onPressed: () {
                context.setLocale(Locale('en'));
              },
              child: const Text("English"),
            ),
          ],
        ),
      ),
    );
  }
}

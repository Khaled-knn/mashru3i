import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:mashrou3i/presentation/widgets/compnents.dart';
import '../../core/cubit/language_cubit.dart';
import '../../core/theme/LocaleKeys.dart';
import '../widgets/custom_button.dart';
import '../../core/network/local/cach_helper.dart'; // <-- مهم

class ChoseScreen extends StatelessWidget {
  const ChoseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.locale.languageCode == 'en';

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset('assets/images/logo.png', width: 320),
              const SizedBox(height: 30),

              // Change Language Button
              CustomButton(
                text: isEnglish ? 'العربية' : 'English',
                onPressed: () {
                  final newLocale = isEnglish ? const Locale('ar') : const Locale('en');
                  context.read<LanguageCubit>().changeLanguage(newLocale, context);
                },
                icon: Icons.language,
                isFilled: false,
                textColor: Colors.black,
                width: 200,
              ),

              const SizedBox(height: 50),

              // Title
              Text(
                LocaleKeys.choose_title.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),


              CustomButton(
                text: LocaleKeys.discover_and_enjoy.tr(),
                onPressed: () => context.push('/UserLogin'),
                textColor: Colors.black,
              ),

              const SizedBox(height: 20),

              CustomButton(
                text: LocaleKeys.unleash_creativity.tr(),
                onPressed: () => context.push('/creatorRegister'),
                isFilled: false,
                textColor: Colors.black,
              ),

              const SizedBox(height: 20),
              CustomButton(
                text: 'continue_as_guest'.tr(),
                onPressed: () async {
                  await CacheHelper.saveData(key: 'guest', value: true);
                  await CacheHelper.removeData(key: 'userToken');

                  if (context.mounted) {
                    context.go('/UserLayout');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('browsing_as_guest'.tr(),
                            style: const TextStyle(color: Colors.black)),
                        backgroundColor: Theme.of(context).primaryColor,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                isFilled: false,
                textColor: Colors.black,
                icon: Icons.lock_open_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

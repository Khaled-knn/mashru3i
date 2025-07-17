import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../core/cubit/language_cubit.dart';
import '../../core/theme/LocaleKeys.dart';
import '../widgets/custom_button.dart';

class ChoseScreen extends StatelessWidget {
  const ChoseScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Image.asset(
                'assets/images/logo.png',
                width: 320,
              ),
              const SizedBox(height: 30),
              // Change Language Button
              CustomButton(
                text: context.locale.languageCode == 'en' ? 'العربية' : 'English',
                onPressed: () {
                  final newLocale = context.locale.languageCode == 'en'
                      ? const Locale('ar')
                      : const Locale('en');
                  context.read<LanguageCubit>().changeLanguage(newLocale, context);
                },
                icon: Icons.language,
                isFilled: false,
                textColor: Colors.black,
                width: 200,
              ),
              const SizedBox(height: 50),
              // Title Text
              Text(
                LocaleKeys.choose_title.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              CustomButton(
                text: LocaleKeys.discover_and_enjoy.tr(),
                onPressed: () {
                  context.push('/UserLogin');
                },
                textColor: Colors.black,

              ),
              const SizedBox(height: 20),
              // Second Button
              CustomButton(
                text: LocaleKeys.unleash_creativity.tr(),
                onPressed: () {
                  context.push('/creatorRegister');
                },
                isFilled: false,
                textColor: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

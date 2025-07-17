import 'dart:ui';
import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

part 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit() : super(LanguageState(locale: Locale('en')));

  Future<void> changeLanguage(Locale locale, BuildContext context) async {
    await context.setLocale(locale);
    emit(LanguageState(locale: locale));
  }
}

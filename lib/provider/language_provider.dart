import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    return const Locale('en');
  }

  /// Called from [main] after reading [SharedPreferences] so the first frame uses the saved locale.
  void applySavedLocale(String code) {
    if (code == 'en' || code == 'ar') {
      state = Locale(code);
    }
  }

  Future<void> changeLanguage(String code) async {
    state = Locale(code);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', code);
  }
}

final languageProvider =
    NotifierProvider<LanguageNotifier, Locale>(LanguageNotifier.new);

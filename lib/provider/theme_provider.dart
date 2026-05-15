import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);

class ThemeNotifier extends Notifier<ThemeMode> {
  static const String themeKey = "is_dark_mode";

  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.light;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    final isDark = prefs.getBool(themeKey) ?? false;

    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(themeKey, isDark);

    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}

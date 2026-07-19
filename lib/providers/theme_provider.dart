import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core_providers.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final Ref _ref;
  static const String _themeKey = 'is_dark_theme';

  ThemeNotifier(this._ref) : super(ThemeMode.light) {
    _loadTheme();
  }

  // Load saved theme preference
  void _loadTheme() {
    final prefs = _ref.read(sharedPreferencesProvider);
    final isDark = prefs.getBool(_themeKey) ?? false;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  // Toggle theme mode and save value to disk
  Future<void> toggleTheme() async {
    final prefs = _ref.read(sharedPreferencesProvider);
    if (state == ThemeMode.light) {
      state = ThemeMode.dark;
      await prefs.setBool(_themeKey, true);
    } else {
      state = ThemeMode.light;
      await prefs.setBool(_themeKey, false);
    }
  }
}

// Global Theme Provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier(ref);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeProviderNotifier extends StateNotifier<bool> {
  ThemeProviderNotifier() : super(false); // default to light mode

  void toggleTheme() {
    state = !state;
  }

  void setDarkMode(bool isDark) {
    state = isDark;
  }
}

final themeProvider = StateNotifierProvider<ThemeProviderNotifier, bool>((ref) {
  return ThemeProviderNotifier();
});

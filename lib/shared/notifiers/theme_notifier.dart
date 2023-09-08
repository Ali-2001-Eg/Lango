import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../enums/app_theme.dart';

class ThemeNotifier extends StateNotifier<AppTheme> {
  ThemeNotifier() : super(AppTheme.light);
  Future<void> initializeTheme() async {

    AppTheme initialTheme = AppTheme.light;

    state = initialTheme;
  }
  void toggleTheme() {
    state = state == AppTheme.light ? AppTheme.dark : AppTheme.light;
  }
}

final themeProvider = StateNotifierProvider((ref) {
  return ThemeNotifier();
});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  String _selectedTheme = 'light';

  ThemeNotifier() {
    // Initialize the selected theme from local storage (SharedPreferences)
    _loadSelectedTheme();
  }

  String get selectedTheme => _selectedTheme;

  void toggleTheme() {
    // Toggle the selected theme
    if (_selectedTheme == 'light') {
      _selectedTheme = 'dark';
    } else {
      _selectedTheme = 'light';
    }

    // Save the selected theme to local storage (SharedPreferences)
    _saveSelectedTheme();

    // Notify listeners that the theme has changed
    notifyListeners();
  }

  void _loadSelectedTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _selectedTheme = prefs.getString('selectedTheme') ?? 'light';

    notifyListeners();
  }

  void _saveSelectedTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedTheme', _selectedTheme);
  }
}

final appThemeProvider =
    ChangeNotifierProvider<ThemeNotifier>((ref) => ThemeNotifier());

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeProvider = ChangeNotifierProvider<LocalizationNotifier>(
    (ref) => LocalizationNotifier());

class LocalizationNotifier extends ChangeNotifier {
  String _selectedLocale = 'en';

  LocalizationNotifier() {
    _loadLocale();
  }
  String get selectedLocale => _selectedLocale;

  void toggleLocale() {
    if (_selectedLocale == 'en') {
      _selectedLocale = 'ar';
    } else {
      _selectedLocale = 'en';
    }
    _saveSelectedLocale();
    notifyListeners();
  }

  void _loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _selectedLocale = prefs.getString('selectedLocale') ?? 'en';

    notifyListeners();
  }

  void _saveSelectedLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLocale', _selectedLocale);
  }
}

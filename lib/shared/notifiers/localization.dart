import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = StateNotifierProvider((ref) => LocalizationNotifier());

class LocalizationNotifier extends StateNotifier<Locale> {
  LocalizationNotifier() : super(const Locale('en'));
  void toggleLocale() {
    state =
        state == const Locale('en') ? const Locale('ar') : const Locale('en');
  }
}

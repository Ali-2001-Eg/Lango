import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/generated/l10n.dart';
import 'package:whatsapp_clone/shared/notifiers/localization.dart';
import 'package:whatsapp_clone/shared/notifiers/theme_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  static const String routeName = '/settings-screen';
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(appThemeProvider);
    final localeNotifier = ref.read(localeProvider);

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              themeNotifier.toggleTheme();
            },
            child: const Text('Toggle Theme'),
          ),
          ElevatedButton(
            onPressed: () {
              localeNotifier.toggleLocale();
            },
            child: Text(S.of(context).language),
          ),
        ],
      ),
    );
  }
}

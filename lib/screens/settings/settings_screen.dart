import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/shared/notifiers/theme_notifier.dart';
class SettingsScreen extends ConsumerWidget {
  static const String routeName = '/settings-screen';
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final themeNotifier = ref.read(themeProvider.notifier);
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            themeNotifier.toggleTheme();
          },
          child: Text('Toggle Theme'),
        ),
      ),
    );
  }
}

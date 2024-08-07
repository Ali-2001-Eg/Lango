import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Lango/controllers/auth_controller.dart';
import 'package:Lango/generated/l10n.dart';
import 'package:Lango/screens/landing/landing_screen.dart';
import 'package:Lango/shared/notifiers/localization.dart';
import 'package:Lango/shared/notifiers/theme_notifier.dart';
import 'package:Lango/shared/utils/functions.dart';

class SettingsScreen extends ConsumerWidget {
  static const String routeName = '/settings-screen';
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(appThemeProvider);
    final localeNotifier = ref.read(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).settings,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //lang
              ListTile(
                title: Text(
                  S.of(context).choose_lang,
                  style: getTextTheme(context, ref),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.language,
                          color: getTheme(context).cardColor,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          S.of(context).app_lang,
                          style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                              fontSize: 15),
                        ),
                      ],
                    ),
                    Container(
                      width: 200,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color:
                                getTheme(context).appBarTheme.backgroundColor!,
                            width: 2),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          onChanged: (value) {
                            localeNotifier.toggleLocale();
                          },
                          value: localeNotifier.selectedLocale,
                          iconSize: 25,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey,
                          ),
                          elevation: 16,
                          underline: Container(
                            height: 2,
                            color: Colors.grey,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: localeNotifier.selectedLocale == 'en'
                                  ? 'en'
                                  : 'ar',
                              child: Text(
                                localeNotifier.selectedLocale,
                                style: getTextTheme(context, ref)
                                    .copyWith(fontSize: 20),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'اللغه العربيه',
                              child: Text(
                                localeNotifier.selectedLocale != 'en'
                                    ? 'en'
                                    : 'ar',
                                style: getTextTheme(context, ref)
                                    .copyWith(fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                thickness: 2,
              ),
              const SizedBox(
                height: 50,
              ),
              //theme
              ListTile(
                title: Text(
                  S.of(context).choose_theme,
                  style: getTextTheme(context, ref),
                ),
                trailing: Switch(
                  value: themeNotifier.selectedTheme == 'light' ? true : false,
                  onChanged: (value) => themeNotifier.toggleTheme(),
                ),
              ),
              const Divider(
                thickness: 2,
              ),
              const SizedBox(
                height: 50,
              ),
              ListTile(
                title: Text(
                  S.of(context).delete_account,
                  style: getTextTheme(context, ref),
                ),
                trailing: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onTap: () {
                  ref.read(authControllerProvider).signOut().then((value) =>
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LandingScreen()),
                          (route) => false));
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

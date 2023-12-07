import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:Lango/controllers/auth_controller.dart';
import 'package:Lango/repositories/firebase_notification_repo.dart';
import 'package:Lango/screens/home_screen.dart';
import 'package:Lango/screens/landing/landing_screen.dart';
import 'package:Lango/shared/notifiers/localization.dart';
import 'package:Lango/shared/notifiers/theme_notifier.dart';
import 'package:Lango/shared/routes/routes.dart';
import 'package:Lango/shared/utils/base/error_screen.dart';
import 'package:Lango/shared/utils/functions.dart';

import 'firebase_options.dart';
import 'generated/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessagingRepo(FirebaseMessaging.instance).init();

  //to listen to providers
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final theme = ref.watch(appThemeProvider);

    return GestureDetector(
      onTap: () {
        FocusScopeNode focus = FocusScope.of(context);
        if (!focus.hasPrimaryFocus) {
          focus.unfocus();
        }
      },
      child: MaterialApp(
        title: 'Lango',
        themeAnimationCurve: Curves.easeInOutQuad,
        themeAnimationDuration: const Duration(seconds: 1),
        locale: locale.selectedLocale == 'en'
            ? const Locale('en')
            : const Locale('ar'),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        theme: lightMode(context, ref),
        darkTheme: darkMode(context, ref),
        themeMode:
            theme.selectedTheme == 'light' ? ThemeMode.light : ThemeMode.dark,
        onGenerateRoute: (settings) => generateRoute(settings),
        //watch to keep tracking user state
        home: Scaffold(
          body: ref.watch(userDataProvider).when(
            data: (user) {
              //print('user is  ${user}');
              if (user == null) {
                return const LandingScreen();
              }
              return const HomeScreen();
            },
            error: (error, stackTrace) {
              return Scaffold(
                body: ErrorScreen(
                    error:
                        'This page doesn\'t exist because ${error.toString()}'),
              );
            },
            loading: () {
              return Scaffold(body: Container());
            },
          ),
        ),
      ),
    );
  }
}

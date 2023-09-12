import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/controllers/auth_controller.dart';
import 'package:whatsapp_clone/screens/home_screen.dart';
import 'package:whatsapp_clone/screens/landing/landing_screen.dart';
import 'package:whatsapp_clone/shared/enums/app_theme.dart';
import 'package:whatsapp_clone/shared/notifiers/localization.dart';
import 'package:whatsapp_clone/shared/notifiers/theme_notifier.dart';
import 'package:whatsapp_clone/shared/routes/routes.dart';
import 'package:whatsapp_clone/shared/utils/base/error_screen.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';
import 'package:whatsapp_clone/shared/widgets/custom_indicator.dart';
import 'generated/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
    return MaterialApp(
      title: 'Chat & Live',
      locale: locale == const Locale('en')
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
      theme: theme.selectedTheme == 'light' ? lightMode : darkMode,
      onGenerateRoute: (settings) => generateRoute(settings),
      //watch to keep tracking user state
      home: Scaffold(
        body: ref.watch(userDataProvider).when(
          data: (user) {
            if (user == null) {
              return const LandingScreen();
            }
            return const HomeScreen();
          },
          error: (error, stackTrace) {
            return const Scaffold(
              body: ErrorScreen(error: 'This page doesn\'t exist'),
            );
          },
          loading: () {
            return const Scaffold(
              body: Center(
                child: CustomIndicator(),
              ),
            );
          },
        ),
      ),
    );
  }
}

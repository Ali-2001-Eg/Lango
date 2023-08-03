import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/screens/auth/login_screen.dart';
import 'package:whatsapp_clone/screens/auth/otp_screen.dart';
import 'package:whatsapp_clone/screens/auth/user_info.dart';
import 'package:whatsapp_clone/screens/chat/chat_screen.dart';
import 'package:whatsapp_clone/screens/home_screen.dart';
import 'package:whatsapp_clone/screens/select_contact/select_contact_screen.dart';
import 'package:whatsapp_clone/shared/utils/base/error_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case LoginScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      );
    case OtpScreen.routeName:
      return MaterialPageRoute(
        builder: (context) {
          //like GetPage
          final verificationId = settings.arguments as String;
          return OtpScreen(verificationId: verificationId);
        },
      );
    case UserInfoScreen.routeName:
      return MaterialPageRoute(
        builder: (context) {
          return const UserInfoScreen();
        },
      );
    case HomeScreen.routeName:
      return MaterialPageRoute(
        builder: (context) {
          return const HomeScreen();
        },
      );
    case SelectContactsScreen.routeName:
      return MaterialPageRoute(
        builder: (context) {
          return const SelectContactsScreen();
        },
      );
    case ChatScreen.routeName:
      final args = settings.arguments as Map<String, dynamic>;
      final name = args['name'];
      final description = args['description'];
      final uid = args['uid'];
      final phoneNumber = args['phoneNumber'];
      final profilePic = args['profilePic'];
      final isOnline = args['isOnline'];
      final List<String> groupId = args['groupId'];
      return MaterialPageRoute(
        builder: (context) {
          return ChatScreen(
              name: name,
              uid: uid,
              groupId: groupId,
              profilePic: profilePic,
              description: description,
              phoneNumber: phoneNumber,
              isOnline: isOnline);
        },
      );
    default:
      return MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: ErrorScreen(error: 'This page doesn\'t exist'),
        ),
      );
  }
}

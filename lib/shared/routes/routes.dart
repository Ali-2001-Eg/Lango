import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Chat_Live/models/status_model.dart';
import 'package:Chat_Live/screens/auth/login_screen.dart';
import 'package:Chat_Live/screens/auth/otp_screen.dart';
import 'package:Chat_Live/screens/auth/user_info.dart';
import 'package:Chat_Live/screens/chat/chat_screen.dart';
import 'package:Chat_Live/screens/chat/expanded_view_scree.dart';
import 'package:Chat_Live/screens/home_screen.dart';
import 'package:Chat_Live/screens/select_contact/select_contact_screen.dart';
import 'package:Chat_Live/screens/settings/settings_screen.dart';
import 'package:Chat_Live/screens/status/confirm_file_status_screen.dart';
import 'package:Chat_Live/screens/status/status_screen.dart';
import 'package:Chat_Live/shared/enums/message_enum.dart';
import 'package:Chat_Live/shared/utils/base/error_screen.dart';

import '../../screens/group/create_group_screen.dart';
import '../../screens/profile/edit_profile_screen.dart';
import '../../screens/search/search_screen.dart';

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
    case SettingsScreen.routeName:
      return MaterialPageRoute(
        builder: (context) {
          return const SettingsScreen();
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
    case EditProfileScreen.routeName:
      return MaterialPageRoute(
        builder: (context) {
          return const EditProfileScreen();
        },
      );
    case SearchScreen.routeName:
      return MaterialPageRoute(
        builder: (context) {
          return const SearchScreen();
        },
      );
    case ConfirmFileStatus.routeName:
      return MaterialPageRoute(
        builder: (context) {
          final file = settings.arguments as File;
          final type = settings.arguments as MessageEnum;
          return ConfirmFileStatus(file: file, type: type);
        },
      );
    case ExpandedViewScreen.routeName:
      return MaterialPageRoute(
        builder: (context) {
          final args = settings.arguments as Map<String, dynamic>;
          final file = args['file'];
          final type = args['type'];
          final caption = args['caption'];
          return ExpandedViewScreen(
              fileUrl: file, fileType: type, caption: caption);
        },
      );
    case StatusScreen.routeName:
      return MaterialPageRoute(
        builder: (context) {
          final args = settings.arguments as Map<String, dynamic>;
          final status = args['status'];
          final receiverUid = args['uid'];
          return StatusScreen(
            status: status,
            receiverUid: receiverUid,
          );
        },
      );
    case CreateGroupScreen.routeName:
      return MaterialPageRoute(
        builder: (context) {
          return const CreateGroupScreen();
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
      final isGroupChat = args['isGroupChat'];
      final token = args['token'];

      final List<String>? groupId = args['groupId'];
      return MaterialPageRoute(
        builder: (context) {
          return ChatScreen(
              name: name,
              uid: uid,
              groupId: groupId,
              profilePic: profilePic,
              isGroupChat: isGroupChat,
              description: description,
              phoneNumber: phoneNumber,
              token: token,
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

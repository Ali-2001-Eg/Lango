// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';
import 'package:http/http.dart' as http;
import '../screens/chat/chat_screen.dart';
import '../shared/utils/base/notifications_config.dart';

final firebaseMessagingRepoProvider =
    Provider((ref) => FirebaseMessagingRepo(FirebaseMessaging.instance));

class FirebaseMessagingRepo extends ChangeNotifier {
  final FirebaseMessaging firebaseMessaging;
  FirebaseMessagingRepo(this.firebaseMessaging) {
    loadToken();
  }
  var notificationToken = '';
  Future<void> init() async {
    firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen(((event) {
      print(event.data.toString());
      print('on message');
    }));
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print(event.data.toString());
      print('on message opened app');
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  Future<void> postNotification({
    required dynamic body,
    required Map<String, dynamic> data,
    required String senderName,
    required String token,
  }) async {
    final url = Uri.parse(NotificationConfig.baseUrl);
    http.Client client = http.Client();
    print('awaited token is: $notificationToken');
    print('load method ${await loadToken()}');
    Map<String, dynamic> payload = {
      "to": token,
      "notification": {
        "title": "$senderName sent you a message",
        "body": body,
      },
      "data": data,
    };
    final response = await client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=${NotificationConfig.serverKey}'
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      print('POST request successful');
      print(response.body);
    } else {
      print('POST request failed with status: ${response.statusCode}');
    }
  }

  _saveToken(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String> loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    notificationToken = prefs.getString('token') ?? '';
    return notificationToken;
  }
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('on background message');
  print(message.data.toString.toString());
  navigatorKey.currentState!.pushNamed(ChatScreen.routeName,
      arguments: message.data.toString.toString());
}

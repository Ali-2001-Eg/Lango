import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Lango/shared/utils/functions.dart';
import 'package:http/http.dart' as http;
import '../screens/chat/chat_screen.dart';
import '../shared/utils/base/notifications_config.dart';

final firebaseMessagingRepoProvider =
    Provider((ref) => FirebaseMessagingRepo(FirebaseMessaging.instance));

class FirebaseMessagingRepo extends ChangeNotifier {
  final FirebaseMessaging firebaseMessaging;
  FirebaseMessagingRepo(this.firebaseMessaging);

  Future<void> init() async {
    firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen(((query) {}));
    FirebaseMessaging.onMessageOpenedApp.listen((query) {});

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  Future<void> postNotification({
    required dynamic body,
    required Map<String, dynamic> data,
    required String title,
    required String token,
  }) async {
    final url = Uri.parse(NotificationConfig.baseUrl);
    http.Client client = http.Client();

    Map<String, dynamic> payload = {
      "to": token,
      "notification": {
        "title": title,
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
    } else {}
  }
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  navigatorKey.currentState!.pushNamed(ChatScreen.routeName,
      arguments: message.data.toString.toString());
}

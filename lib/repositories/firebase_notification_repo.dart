// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_clone/screens/call/call_screen.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';
import 'package:http/http.dart' as http;
import '../screens/chat/chat_screen.dart';
import '../shared/utils/base/notifications_config.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

final firebaseMessagingRepoProvider =
    Provider((ref) => FirebaseMessagingRepo(FirebaseMessaging.instance));

class FirebaseMessagingRepo extends ChangeNotifier {
  final FirebaseMessaging firebaseMessaging;
  FirebaseMessagingRepo(this.firebaseMessaging);

  Future<void> init() async {
    firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen(((query) {
      print(query.data.toString());
      print('on message');
    }));
    FirebaseMessaging.onMessageOpenedApp.listen((query) {
      print(query.data.toString());
      print('on message opened app');
    });

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
      print('POST request successful');
      print(response.body);
    } else {
      print('POST request failed with status: ${response.statusCode}');
    }
  }

  postCallingNotification({
    required String title,
    required String body,
    required String token,
    required Map<String, dynamic> data,
    required String channelName,
  }) {
    AwesomeNotifications().initialize('defaultIcon', [
      NotificationChannel(
        channelKey: 'call_channel',
        channelName: channelName,
        channelDescription: 'Calling Notification',
        defaultColor: Colors.redAccent,
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        channelShowBadge: true,
        defaultRingtoneType: DefaultRingtoneType.Ringtone,
      ),
    ]);
    postNotification(body: body, data: data, title: title, token: token);
    FirebaseMessaging.onBackgroundMessage(callingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(callingBackgroundHandler);
  }
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('on background message');
  print(message.data.toString.toString());
  navigatorKey.currentState!.pushNamed(ChatScreen.routeName,
      arguments: message.data.toString.toString());
}

Future<void> callingBackgroundHandler(RemoteMessage message) async {
  String? title = message.notification!.title;
  String? body = message.notification!.body;
  var createNotification = AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 123,
      channelKey: 'call_channel',
      color: Colors.white,
      body: body,
      title: title,
      category: NotificationCategory.Call,
      wakeUpScreen: true,
      fullScreenIntent: true,
      autoDismissible: false,
      backgroundColor: Colors.orange,
    ),
    actionButtons: [
      NotificationActionButton(
        key: 'ACCEPT',
        label: 'ACCEPT',
        autoDismissible: true,
        color: Colors.greenAccent,
      ),
      NotificationActionButton(
        key: 'DECLINE',
        label: 'DECLINE',
        autoDismissible: true,
        color: Colors.greenAccent,
      ),
    ],
  );
  AwesomeNotifications().actionStream.listen((query) {
    if (query.buttonKeyPressed == 'ACCEPT') {
      print('call Accepted');
    } else if (query.buttonKeyPressed == 'DECLINE') {
      print('call Declined');
    } else {
      print('Clicked on notification');
    }
  });
  /* navigatorKey.currentState!.pushNamed(CallScreen.routeName,
      arguments: message.data.toString.toString()); */
}

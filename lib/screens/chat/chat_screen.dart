import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/controllers/call_controller.dart';
import 'package:whatsapp_clone/controllers/chat_controller.dart';
import 'package:whatsapp_clone/models/user_model.dart';
import 'package:whatsapp_clone/screens/call/call_pickup_screen.dart';
import 'package:whatsapp_clone/shared/widgets/bottom_chat_field.dart';
import 'package:whatsapp_clone/shared/widgets/custom_indicator.dart';

import '../../controllers/auth_controller.dart';
import '../../shared/widgets/chat_list.dart';

class ChatScreen extends ConsumerWidget {
  static const routeName = '/chat-screen';
  final String name;
  final String uid;
  final String description;
  final String phoneNumber;
  final String profilePic;
  final List<String>? groupId;
  final bool isOnline;
  final bool isGroupChat;
  const ChatScreen({
    Key? key,
    required this.name,
    required this.uid,
    required this.description,
    required this.phoneNumber,
    required this.isGroupChat,
    required this.profilePic,
    this.groupId,
    required this.isOnline,
  }) : super(key: key);

  void makeCall(WidgetRef ref, BuildContext context) {
    ref
        .read(callControllerProvider)
        .call(name, profilePic, isGroupChat, uid, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // print(ref.read(chatControllerProvider).user?.name);
    return CallPickupScreen(
      scaffold: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: isGroupChat
              ? Text(name)
              : StreamBuilder<UserModel>(
                  stream: ref.read(authControllerProvider).userData(uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CustomIndicator();
                    } else if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    } else {
                      return Column(
                        children: [
                          Text(name),
                          Text(snapshot.data!.isOnline ? 'online' : 'offline',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500)),
                        ],
                      );
                    }
                  }),
          actions: [
            IconButton(
                onPressed: () => makeCall(ref, context),
                icon: const Icon(Icons.video_call)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.call)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
          ],
        ),
        body: Column(
          children: [
            Expanded(
                child: ChatList(receiverUid: uid, isGroupChat: isGroupChat)),
            BottomChatFieldWidget(receiverUid: uid, isGroupChat: isGroupChat),
          ],
        ),
      ),
    );
  }
}

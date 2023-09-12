import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/controllers/call_controller.dart';
import 'package:whatsapp_clone/controllers/chat_controller.dart';
import 'package:whatsapp_clone/generated/l10n.dart';
import 'package:whatsapp_clone/models/user_model.dart';
import 'package:whatsapp_clone/screens/call/call_pickup_screen.dart';
import 'package:whatsapp_clone/shared/enums/app_theme.dart';
import 'package:whatsapp_clone/shared/notifiers/theme_notifier.dart';
import 'package:whatsapp_clone/shared/utils/colors.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';
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
    final appTheme = ref.watch(appThemeProvider);
    // print(ref.read(chatControllerProvider).user?.name);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: CallPickupScreen(
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
                            Text(
                              name,
                              style: getTextTheme(context)!.copyWith(
                                  color: appTheme.selectedTheme == 'light'
                                      ? lightScaffold
                                      : Colors.white),
                            ),
                            Text(
                                snapshot.data!.isOnline
                                    ? S.of(context).online
                                    : S.of(context).offline,
                                style: getTextTheme(context)!.copyWith(
                                  height: 0,
                                  fontSize: 13,
                                )),
                          ],
                        );
                      }
                    }),
            actions: [
              IconButton(
                  onPressed: () => makeCall(ref, context),
                  icon: const Icon(
                    Icons.video_call,
                    size: 30,
                  )),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    colorFilter: appTheme.selectedTheme == 'light'
                        ? const ColorFilter.linearToSrgbGamma()
                        : const ColorFilter.srgbToLinearGamma(),
                    fit: BoxFit.fill,
                    image: const AssetImage('assets/images/background.png'))),
            child: Column(
              children: [
                Expanded(
                    child:
                        ChatList(receiverUid: uid, isGroupChat: isGroupChat)),
                BottomChatFieldWidget(
                  receiverUid: uid,
                  isGroupChat: isGroupChat,
                  isStatusReply: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

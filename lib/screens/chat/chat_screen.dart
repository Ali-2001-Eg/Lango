// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Chat_Live/controllers/call_controller.dart';
import 'package:Chat_Live/controllers/chat_controller.dart';
import 'package:Chat_Live/controllers/group_controller.dart';
import 'package:Chat_Live/controllers/message_reply_controller.dart';
import 'package:Chat_Live/generated/l10n.dart';
import 'package:Chat_Live/models/user_model.dart';
import 'package:Chat_Live/screens/call/call_pickup_screen.dart';
import 'package:Chat_Live/screens/decription/description_screen.dart';
import 'package:Chat_Live/screens/home_screen.dart';
import 'package:Chat_Live/shared/notifiers/theme_notifier.dart';
import 'package:Chat_Live/shared/utils/colors.dart';
import 'package:Chat_Live/shared/utils/functions.dart';
import 'package:Chat_Live/shared/widgets/bottom_chat_field.dart';
import 'package:Chat_Live/shared/widgets/custom_button.dart';
import 'package:Chat_Live/shared/widgets/custom_indicator.dart';

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
  final String token;
  const ChatScreen({
    Key? key,
    required this.name,
    required this.uid,
    required this.description,
    required this.phoneNumber,
    required this.isGroupChat,
    required this.profilePic,
    this.groupId,
    required this.token,
    required this.isOnline,
  }) : super(key: key);

  void makeCall(WidgetRef ref, BuildContext context) {
    ref
        .read(callControllerProvider)
        .call(name, profilePic, isGroupChat, uid, context, token)
        .then((value) => ref.read(chatControllerProvider).notifyReceiver(
              body: S.of(context).call_notification_body,
              receiverUid: uid,
              token: token,
              title: S.of(context).call_notification_title,
              isGroupChat: isGroupChat,
            ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(appThemeProvider);
    return WillPopScope(
      onWillPop: () async {
        ref.read(messageReplyProvider.state).update((state) => null);
        Navigator.pushNamedAndRemoveUntil(
            context, HomeScreen.routeName, (route) => false);
        return true;
      },
      child: CallPickupScreen(
        scaffold: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            shadowColor: Colors.black,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_sharp),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, HomeScreen.routeName, (route) => false),
            ),
            title: isGroupChat
                ? Text(
                    name,
                    style: getTextTheme(context, ref).copyWith(
                        color: appTheme.selectedTheme == 'light'
                            ? lightScaffold
                            : Colors.white),
                  )
                : StreamBuilder<UserModel>(
                    stream: ref.read(authControllerProvider).userData(uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      } else if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      } else {
                        return Column(
                          children: [
                            Text(
                              name,
                              style: getTextTheme(context, ref).copyWith(
                                  color: appTheme.selectedTheme == 'light'
                                      ? lightScaffold
                                      : Colors.white),
                            ),
                            Text(
                                snapshot.data!.isOnline
                                    ? S.of(context).online
                                    : S.of(context).offline,
                                style: getTextTheme(context, ref).copyWith(
                                  height: 0,
                                  color: appTheme.selectedTheme == 'light'
                                      ? greyColor
                                      : Colors.white,
                                  fontSize: 13,
                                )),
                          ],
                        );
                      }
                    }),
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DescriptionScreen(
                                isGroupChat: isGroupChat,
                                name: name,
                                phoneNumber: phoneNumber,
                                pic: profilePic,
                                description: description,
                                id: uid)));
                  },
                  icon: const Icon(
                    Icons.info,
                    size: 20,
                  )),
              isGroupChat
                  ? StreamBuilder<bool>(
                      stream:
                          ref.read(groupControllerProvider).isUserJoined(uid),
                      builder: (context, snapshot) {
                        return IconButton(
                            onPressed: () => snapshot.data!
                                ? makeCall(ref, context)
                                : customSnackBar(
                                    !isArabic
                                        ? 'You must join $name first to make call.'
                                        : 'لاتمام المكالمات انضم ل مجموعه $name',
                                    context),
                            icon: const Icon(
                              Icons.call,
                              size: 30,
                            ));
                      })
                  : IconButton(
                      onPressed: () => makeCall(ref, context),
                      icon: const Icon(
                        Icons.call,
                        size: 30,
                      )),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    colorFilter: appTheme.selectedTheme == 'light'
                        ? const ColorFilter.linearToSrgbGamma()
                        : null,
                    fit: BoxFit.fill,
                    image: const AssetImage('assets/images/background.png'))),
            child: StreamBuilder<bool>(
                stream: ref.read(groupControllerProvider).isUserJoined(uid),
                builder: (context, snapshot) {
                  print('user is  ${snapshot.data}');
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CustomIndicator();
                  }
                  return Column(
                    children: [
                      Expanded(
                          child: ChatList(
                        receiverUid: uid,
                        isGroupChat: isGroupChat,
                        token: token,
                      )),
                      (isGroupChat && !snapshot.data!)
                          ? Container(
                              height: size(context).height / 4,
                              width: size(context).width,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: getTheme(context).cardColor,
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    !isArabic
                                        ? 'You must join $name first to make messages.'
                                        : 'لاتمام المحادثات انضم لمجموعه $name ',
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.white70),
                                  ),
                                  CustomButton(
                                    text: S.of(context).join_group,
                                    onPress: () {
                                      ref
                                          .read(groupControllerProvider)
                                          .joinGroup(uid);
                                    },
                                  )
                                ],
                              ),
                            )
                          : BottomChatFieldWidget(
                              receiverUid: uid,
                              isGroupChat: isGroupChat,
                            ),
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }
}

// ignore_for_file: deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Lango/controllers/chat_controller.dart';
import 'package:Lango/generated/l10n.dart';
import 'package:Lango/models/message_model.dart';
import 'package:Lango/repositories/auth_repo.dart';
import 'package:Lango/shared/enums/message_enum.dart';
import 'package:Lango/shared/widgets/custom_indicator.dart';
import '../../controllers/message_reply_controller.dart';
import 'message_tile.dart';

class ChatList extends ConsumerStatefulWidget {
  final String receiverUid;
  final bool isGroupChat;
  final String token;
  const ChatList({
    Key? key,
    required this.receiverUid,
    required this.isGroupChat,
    required this.token,
  }) : super(key: key);

  @override
  ConsumerState createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: StreamBuilder<List<MessageModel>>(
          stream: widget.isGroupChat
              ? ref
                  .read(chatControllerProvider)
                  .groupChatStream(widget.receiverUid)
              : ref.read(chatControllerProvider).chatStream(widget.receiverUid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CustomIndicator());
            } else {
              //to scroll to the new message when chatting automatically
              SchedulerBinding.instance.addPostFrameCallback((_) {
                _scrollController
                    .jumpTo(_scrollController.position.maxScrollExtent);
              });
              return ListView.builder(
                controller: _scrollController,
                itemCount: snapshot.data!.length,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final message = snapshot.data![index];
                  //debugPrint('chat list token is  ${widget.token}');
                  // debugPrint(message.isSeen);
                  // debugPrint('current uuid is ${FirebaseAuth.instance.currentUser!.uid}');
                  // debugPrint('length is ${snapshot.data!.length}');
                  // debugPrint('receiver uid is ${message.receiverUid}');
                  //to decrease performance overhead
                  if (!message.isSeen &&
                      message.receiverUid ==
                          FirebaseAuth.instance.currentUser!.uid) {
                    ref.read(chatControllerProvider).setMessageSeen(
                        message.id, context, widget.receiverUid);
                  }
                  if (!message.isSeen) {
                    ref.read(chatControllerProvider).notifyReceiver(
                          title: S.of(context).message_notification_title,
                          body: message.messageType == MessageEnum.text
                              ? message.messageText
                              : message.messageType.type,
                          receiverUid: widget.receiverUid,
                          token: widget.token,
                          isGroupChat: widget.isGroupChat,
                        );
                  }
                  // debugPrint(message.receiverUid);
                  //debugPrint(message.senderName);
                  return MessageTile(
                    message: message.messageText,
                    date: message.timeSent.toString(),
                    senderName: message.senderName,
                    isMe: widget.isGroupChat
                        ? message.senderUid ==
                            ref
                                .read(authRepositoryProvider)
                                .auth
                                .currentUser!
                                .uid
                        : message.receiverUid !=
                            ref
                                .read(authRepositoryProvider)
                                .auth
                                .currentUser!
                                .uid,
                    messageType: message.messageType,
                    messageReply: message.messageReply,
                    username: message.repliedTo,
                    messageReplyType: message.messageReplyType,
                    caption: message.caption ?? '',
                    onLeftOrRightSwipe: () => _onMessageSwipe(
                      message.messageText,
                      message.receiverUid ==
                          ref.watch(chatControllerProvider).user?.uid,
                      message.messageType,
                    ),
                    isGroupchat: widget.isGroupChat,
                    receiverUid: message.receiverUid,
                    messageId: message.id,
                    isSeen: message.receiverUid != message.senderUid
                        ? message.isSeen
                        : true,
                  );
                },
              );
            }
          }),
    );
  }

  void _onMessageSwipe(String message, bool isMe, MessageEnum messageType) {
    //state provider
    ref.read(messageReplyProvider.state).update((state) =>
        MessageReply(message: message, messageType: messageType, isMe: isMe));
  }
}

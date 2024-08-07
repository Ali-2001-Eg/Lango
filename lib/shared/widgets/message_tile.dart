// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:Lango/shared/utils/functions.dart';
import 'package:Lango/shared/widgets/message_widget.dart';

import '../../controllers/chat_controller.dart';
import '../../controllers/message_reply_controller.dart';
import '../../repositories/auth_repo.dart';
import '../enums/message_enum.dart';

class MessageTile extends ConsumerWidget {
  final String message;
  final String date;
  final String messageId;
  final String receiverUid;
  final bool isMe;
  final MessageEnum messageType;
  //for me swipe to left
  final VoidCallback onLeftOrRightSwipe;
  final String username;
  final String messageReply;
  final String caption;
  final MessageEnum messageReplyType;
  final bool isSeen;
  final String senderName;
  final bool isGroupchat;
  const MessageTile({
    Key? key,
    required this.message,
    required this.date,
    required this.isMe,
    required this.messageType,
    required this.onLeftOrRightSwipe,
    required this.messageReply,
    required this.username,
    required this.messageId,
    required this.senderName,
    required this.receiverUid,
    this.caption = '',
    required this.isGroupchat,
    required this.messageReplyType,
    required this.isSeen,
  }) : super(key: key);
  @override
  Widget build(BuildContext context, ref) {
    final bool isReplying = messageReply.isNotEmpty;
    return SwipeTo(
      onLeftSwipe: isMe ? onLeftOrRightSwipe : null,
      onRightSwipe: isMe ? null : onLeftOrRightSwipe,
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: size(context).width / 1.5,
            // minHeight: size(context).height * 0.1,
            minWidth: size(context).width / 3,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: isMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
            color: messageType == MessageEnum.gif ||
                    messageType == MessageEnum.image ||
                    messageType == MessageEnum.video ||
                    messageType == MessageEnum.audio
                ? null
                : isMe
                    ? getTheme(context).cardColor
                    : const Color(0xff1e293b),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isGroupchat && !isMe) ...[
                    Text(
                      '~$senderName',
                      style: const TextStyle(color: Colors.white),
                    )
                  ],
                  customPopupMenuButton(ref, context),
                ],
              ),
              if (isReplying) ...[
                Container(
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: getTheme(context).hoverColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {},
                        child: Text(
                          isMe
                              ? '~you '
                              : isArabic
                                  ? '$username قام بالرد عليك'
                                  : '$username replied for you',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      MessageWidget(
                        messageType: messageReplyType,
                        message: messageReply,
                        textColor: Colors.grey[900]!,
                        receiverUid: receiverUid,
                      ),
                    ],
                  ),
                ),
              ],
              MessageWidget(
                messageType: messageType,
                message: message,
                caption: caption,
                receiverUid: receiverUid,
              ),
              Container(
                decoration: BoxDecoration(
                  //color: Colors.grey,
                  borderRadius: BorderRadius.circular(5),
                  /* boxShadow: const [
                    BoxShadow(
                        color: Colors.black38,
                        offset: Offset(0, 5),
                        spreadRadius: 3,
                        blurRadius: 1,
                        blurStyle: BlurStyle.inner)
                  ], */
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('h:mm a').format(DateTime.parse(date)),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.done_all,
                        size: 20,
                        color: isSeen && !isMe
                            ? CupertinoColors.systemBlue
                            : Colors.black45,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuButton<dynamic> customPopupMenuButton(WidgetRef ref, context) {
    return PopupMenuButton(
      icon: const Icon(
        Icons.more_vert,
        color: Colors.grey,
      ),
      color: getTheme(context).appBarTheme.backgroundColor,
      iconSize: 30,
      itemBuilder: (context) => [
        if (messageType == MessageEnum.text)
          PopupMenuItem(
              child: const Icon(
                Icons.copy,
                color: Colors.green,
              ),
              onTap: () => ref
                  .read(chatControllerProvider)
                  .copyToClipboard(message, context)),
        if (receiverUid !=
                ref.read(authRepositoryProvider).auth.currentUser!.uid &&
            !isGroupchat)
          PopupMenuItem(
              child: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
              onTap: () {
                ref
                    .read(chatControllerProvider)
                    .deleteMessage(messageId, context, receiverUid);
              }),
        PopupMenuItem(
          child: const Icon(
            Icons.replay_rounded,
            color: Colors.green,
          ),
          onTap: () => ref
              .read(messageReplyProvider.state)
              .update((state) => MessageReply(
                    message: message,
                    messageType: messageType,
                    isMe: receiverUid ==
                        ref.read(authRepositoryProvider).auth.currentUser!.uid,
                  )),
        )
      ],
    );
  }
}

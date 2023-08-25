import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:whatsapp_clone/shared/utils/colors.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';
import 'package:whatsapp_clone/shared/widgets/message_widget.dart';
import 'package:whatsapp_clone/shared/widgets/time_text_formatter.dart';

import '../enums/message_enum.dart';

class MessageTile extends StatelessWidget {
  final String message;
  final String date;
  final bool isMe;
  final MessageEnum messageType;
  //for me swipe to left
  final VoidCallback onLeftOrRightSwipe;
  final String username;
  final String messageReply;
  final String caption;
  final MessageEnum messageReplyType;
  final bool isSeen;
  const MessageTile({
    Key? key,
    required this.message,
    required this.date,
    required this.isMe,
    required this.messageType,
    required this.onLeftOrRightSwipe,
    required this.messageReply,
    required this.username,
    this.caption = '',
    required this.messageReplyType,
    required this.isSeen,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final bool isReplying = messageReply.isNotEmpty;
    return SwipeTo(
      onLeftSwipe: isMe ? onLeftOrRightSwipe : null,
      onRightSwipe: isMe ? null : onLeftOrRightSwipe,
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 45, minHeight: 40),
          child: Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: messageType == MessageEnum.image ||
                    messageType == MessageEnum.video ||
                    messageType == MessageEnum.pdf ||
                    messageType == MessageEnum.gif
                ? backgroundColor
                : messageColor,
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: size(context).width - 50,
                      minWidth: size(context).width / 3),
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 10, bottom: 10),
                    child: Column(
                      children: [
                        if (isReplying) ...[
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: size(context).width - 50,
                              minWidth: size(context).width / 3,
                            ),
                            // color: Colors.red,
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            padding: const EdgeInsets.all(5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {

                                  },
                                  child: Text(
                                    isMe?'~you ':username,
                                    style:  TextStyle(
                                        fontWeight: FontWeight.bold,color: Colors.grey[900]),
                                  ),
                                ),
                                MessageWidget(
                                  messageType: messageReplyType,
                                  message: messageReply,
                                  textColor: Colors.grey[900]!,

                                ),
                              ],
                            ),
                          ),
                        ],
                        MessageWidget(
                          messageType: messageType,
                          message: message,
                          caption: caption,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                  color: Colors.grey,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        offset: Offset(0,5),
                        spreadRadius: 3,
                        blurRadius: 1,
                        blurStyle: BlurStyle.inner
                      )
                    ]
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat('h:mm a').format(DateTime.parse(date)),
                          style:
                              const TextStyle(color: Colors.black, fontSize: 12),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                         Icon(
                          Icons.done_all,
                          size: 20,
                          color: isSeen?CupertinoColors.systemBlue:Colors.black45,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

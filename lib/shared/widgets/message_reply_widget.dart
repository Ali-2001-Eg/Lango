import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/shared/utils/colors.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';
import 'package:whatsapp_clone/shared/widgets/message_widget.dart';

import '../../controllers/message_reply_controller.dart';

class MessageReplyWidget extends ConsumerWidget {
  final String receiverUid;

  const MessageReplyWidget({
    super.key,
    required this.receiverUid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageReply = ref.watch(messageReplyProvider);

    return Container(
      width: size(context).width / 1.3,
      decoration: BoxDecoration(
        color: getTheme(context).appBarTheme.backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  !messageReply!.isMe ? '~ Me' : '~ Opposite',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                child: const Icon(
                  Icons.close,
                  size: 20,
                ),
                onTap: () => _cancelReply(ref),
              )
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          MessageWidget(
            message: messageReply.message,
            messageType: messageReply.messageType,
            receiverUid: receiverUid,
          )
        ],
      ),
    );
  }

  void _cancelReply(WidgetRef ref) {
    ref.read(messageReplyProvider.state).update((state) => null);
  }
}

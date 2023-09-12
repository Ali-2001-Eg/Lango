import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/shared/utils/colors.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';
import 'package:whatsapp_clone/shared/widgets/message_widget.dart';

import '../../controllers/message_reply_controller.dart';

class MessageReplyWidget extends ConsumerWidget {
  final bool fromStatusScreen;
  const MessageReplyWidget({super.key, required this.fromStatusScreen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageReply = ref.watch(messageReplyProvider);

    return Container(
      width: 300,
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(10), topLeft: Radius.circular(10)),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  messageReply!.isMe ? '~ Me' : '~ Opposite',
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
          (fromStatusScreen)
              ? ConstrainedBox(
                  constraints:
                      BoxConstraints(maxHeight: size(context).height / 10),
                  child: MessageWidget(
                      message: messageReply.message,
                      messageType: messageReply.messageType),
                )
              : MessageWidget(
                  message: messageReply.message,
                  messageType: messageReply.messageType)
        ],
      ),
    );
  }

  void _cancelReply(WidgetRef ref) {
    ref.read(messageReplyProvider.state).update((state) => null);
  }
}

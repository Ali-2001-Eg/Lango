import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/controllers/chat_controller.dart';
import 'package:whatsapp_clone/models/message_model.dart';
import 'package:whatsapp_clone/shared/utils/base/error_screen.dart';
import 'package:whatsapp_clone/shared/widgets/custom_indicator.dart';
import 'package:whatsapp_clone/shared/widgets/sender_message_tile.dart';

import 'message_tile.dart';

class ChatList extends ConsumerStatefulWidget {
  final String receiverUid;
  const ChatList({Key? key, required this.receiverUid}) : super(key: key);

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
    return StreamBuilder<List<MessageModel>>(
        stream: ref.read(chatControllerProvider).chatStream(widget.receiverUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomIndicator();
          } else if (snapshot.hasError) {
            return ErrorScreen(error: snapshot.error.toString());
          } else {
            //to scroll to the new message when chatting automatically
            SchedulerBinding.instance.addPostFrameCallback((_) {
              _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
            });
            return ListView.builder(
              controller: _scrollController,
              itemCount: snapshot.data!.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final message = snapshot.data![index];
                if (message.receiverUid ==
                    ref.watch(chatControllerProvider).user.uid) {
                  return MessageTile(
                    message: message.messageText,
                    date: message.timeSent,
                  );
                }
                return ReceivedMessage(
                    message: message.messageText, date: message.timeSent);
              },
            );
          }
        });
  }
}


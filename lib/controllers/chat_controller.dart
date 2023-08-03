import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/controllers/auth_controller.dart';
import 'package:whatsapp_clone/models/chat_contacts_model.dart';
import 'package:whatsapp_clone/repository/chat_repo.dart';

import '../models/message_model.dart';
import '../models/user_model.dart';

class ChatController {
  final ChatRepo chatRepo;
  final ProviderRef ref;

  ChatController(this.chatRepo, this.ref);

  void sendTextMessage(
      BuildContext context, String messageText, String receiverUid) {
    //to handel errors
    ref.read(userDataProvider).whenData((value) async =>
        chatRepo.sendTextMessage(
            messageText: messageText,
            context: context,
            receiverUid: receiverUid,
            sender: value!));
  }

  UserModel get user => chatRepo.user!;
  Stream<List<ChatContactModel>> get contacts => chatRepo.getChatContacts;
  Stream<List<MessageModel>> chatStream(String receiverUid) =>
      chatRepo.getMessages(receiverUid);
}

final chatControllerProvider = Provider((ref) {
  //watch to keep tracking
  final chatRepo = ref.watch(chatRepoProvider);
  return ChatController(chatRepo, ref);
});

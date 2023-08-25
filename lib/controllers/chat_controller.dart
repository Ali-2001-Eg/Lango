import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/controllers/auth_controller.dart';
import 'package:whatsapp_clone/controllers/message_reply_controller.dart';
import 'package:whatsapp_clone/models/chat_contacts_model.dart';
import 'package:whatsapp_clone/repository/chat_repo.dart';
import 'package:whatsapp_clone/shared/enums/message_enum.dart';

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
            sender: value!,
            messageReply: ref.read(messageReplyProvider)));
    ref.read(messageReplyProvider.state).update((state) => null);
  }

  void sendGifMessage(BuildContext context, String gifUrl, String receiverUid) {
    //to handel errors
    //https://giphy.com/gifs/imoji-laughing-3ohzdQJJ2JGvMSYvdu ==>
    //https://media0.giphy.com/media/v1.Y2lkPTc5MGI3NjExdzA2bXZyeWxmZDZkbnc4d21kNGlpaHJ3dXlsaWFwM3drNms1bzhtbiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9cw/3ohzdQJJ2JGvMSYvdu/giphy.gif
    print(gifUrl);
    int gifUrlPartIndex = gifUrl.lastIndexOf('-') + 1;
    String gifUrlPart = gifUrl.substring(gifUrlPartIndex);
    String newGifUrl =
        'https://media0.giphy.com/media/v1.Y2lkPTc5MGI3NjExdzA2bXZyeWxmZDZkbnc4d21kNGlpaHJ3dXlsaWFwM3drNms1bzhtbiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9cw/$gifUrlPart/giphy.gif';
    ref.read(userDataProvider).whenData((value) async =>
        chatRepo.sendGifMessage(
            gifUrl: newGifUrl,
            context: context,
            receiverUid: receiverUid,
            sender: value!,
            messageReply: ref.read(messageReplyProvider)));
    ref.read(messageReplyProvider.state).update((state) => null);
  }

  void sendFileMessage(BuildContext context, File file, String receiverUid,
      MessageEnum fileType,String? caption) {
    //to handel errors
    ref.read(userDataProvider).whenData((value) async =>
        chatRepo.sendFileMessage(
            context: context,
            file: file,
            ref: ref,
            senderData: value!,
            fileType: fileType,
            caption: caption,
            messageReply: ref.read(messageReplyProvider)));
    ref.read(messageReplyProvider.state).update((state) => null);
  }

  UserModel? get user => chatRepo.user;

  Stream<List<ChatContactModel>> get contacts => chatRepo.getChatContacts;
  Stream<List<MessageModel>> chatStream(String receiverUid) =>
      chatRepo.getMessages(receiverUid);
  void setMessageSeen(String messageId,BuildContext context,String receiverUid){
    chatRepo.setMessageSeen(messageId, context, receiverUid);
  }
}

final chatControllerProvider = Provider((ref) {
  //watch to keep tracking
  final chatRepo = ref.watch(chatRepoProvider);
  return ChatController(chatRepo, ref);
});

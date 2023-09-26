import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/controllers/auth_controller.dart';
import 'package:whatsapp_clone/controllers/message_reply_controller.dart';
import 'package:whatsapp_clone/models/chat_contacts_model.dart';
import 'package:whatsapp_clone/models/group_model.dart';
import 'package:whatsapp_clone/repositories/chat_repo.dart';
import 'package:whatsapp_clone/shared/enums/message_enum.dart';

import '../models/message_model.dart';
import '../models/user_model.dart';
import '../shared/utils/functions.dart';

class ChatController {
  final ChatRepo chatRepo;
  final ProviderRef ref;

  ChatController(this.chatRepo, this.ref);

  Future<void> sendTextMessage(BuildContext context, String messageText,
      String receiverUid, bool isGroupChat) async {
    //to handel errors
    ref.read(userDataProvider).whenData((value) async =>
        chatRepo.sendTextMessage(
            messageText: messageText,
            context: context,
            receiverUid: receiverUid,
            isGroupChat: isGroupChat,
            sender: value!,
            messageReply: ref.read(messageReplyProvider)));
    ref.read(messageReplyProvider.state).update((state) => null);
  }

  void sendGifMessage(BuildContext context, String gifUrl, String receiverUid,
      bool isGroupChat) {
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
            isGroupChat: isGroupChat,
            receiverUid: receiverUid,
            sender: value!,
            messageReply: ref.read(messageReplyProvider)));
    ref.read(messageReplyProvider.state).update((state) => null);
  }

  void sendFileMessage(BuildContext context, File file, String receiverUid,
      MessageEnum fileType, String? caption, bool isGroupChat) {
    //to handel errors
    ref.read(userDataProvider).whenData((value) async =>
        chatRepo.sendFileMessage(
            context: context,
            file: file,
            ref: ref,
            senderData: value!,
            fileType: fileType,
            isGroupChat: isGroupChat,
            receiverUid: receiverUid,
            caption: caption,
            messageReply: ref.read(messageReplyProvider)));
    ref.read(messageReplyProvider.state).update((state) => null);
  }

  UserModel? get user => chatRepo.user;

  Stream<List<ChatContactModel>> get contacts => chatRepo.getChatContacts;

  Stream<List<GroupModel>> get groups => chatRepo.getChatGroups;

  Stream<List<MessageModel>> chatStream(String receiverUid) =>
      chatRepo.getMessages(receiverUid);
  Stream<List<MessageModel>> groupChatStream(String groupId) =>
      chatRepo.getGroupMessages(groupId);
  void setMessageSeen(
      String messageId, BuildContext context, String receiverUid) {
    chatRepo.setMessageSeen(messageId, context, receiverUid);
  }

  void notifyReceiver(
          {required String body,
          required String token,
          required String receiverUid,
          required bool isGroupChat}) =>
      ref.read(userDataProvider).whenData((value) => chatRepo.sendNotification(
          body: body,
          sender: value!,
          token: token,
          receiverUid: receiverUid,
          isGroupChat: isGroupChat));
  void deleteMessage(
    String messageId,
    BuildContext context,
    String receiverUid,
  ) {
    chatRepo.deleteMessage(messageId, context, receiverUid).then(
        (value) => customSnackBar('message deleted Successfully', context));
  }

  void copyToClipboard(String message) {
    chatRepo.copyMessageToClipboard(message);
  }
}

final chatControllerProvider = Provider((ref) {
  //watch to keep tracking
  final chatRepo = ref.watch(chatRepoProvider);
  return ChatController(chatRepo, ref);
});

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/models/chat_contacts_model.dart';
import 'package:whatsapp_clone/models/message_model.dart';
import 'package:whatsapp_clone/models/user_model.dart';
import 'package:whatsapp_clone/shared/enums/message_enum.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';

import '../controllers/message_reply_controller.dart';
import '../shared/repos/firebase_storage_repo.dart';

class ChatRepo {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  ChatRepo(this.auth, this.firestore);
  UserModel? user;
  //send text message
  Future<void> sendTextMessage({
    required String messageText,
    required BuildContext context,
    required String receiverUid,
    required UserModel sender,
    required MessageReply? messageReply,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel receiverUserData;
      var receiverData =
          await firestore.collection('users').doc(receiverUid).get();
      receiverUserData = UserModel.fromJson(receiverData.data()!);
      _saveContacts(sender, receiverUserData, true, messageText, timeSent,
          receiverUid, MessageEnum.text.type);
      //to generate unique identifier
      var messageId = const Uuid().v1();
      _saveMessages(
        receiverUid: receiverUid,
        messageText: messageText,
        timeSent: timeSent,
        senderName: sender.name,
        receiverName: receiverUserData.name,
        messageType: MessageEnum.text,
        messageId: messageId,
        messageReply: messageReply,
        caption: null,
      );
    } catch (e) {
      customSnackBar(e.toString(), context);
    }
  }

  Future<void> sendGifMessage({
    required String gifUrl,
    required BuildContext context,
    required String receiverUid,
    required UserModel sender,
    required MessageReply? messageReply,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel receiverUserData;
      var receiverData =
          await firestore.collection('users').doc(receiverUid).get();
      receiverUserData = UserModel.fromJson(receiverData.data()!);
      _saveContacts(sender, receiverUserData, false, gifUrl, timeSent,
          receiverUid, MessageEnum.gif.type.toUpperCase());
      //to generate unique identifier
      var messageId = const Uuid().v1();
      _saveMessages(
        receiverUid: receiverUid,
        messageText: gifUrl,
        timeSent: timeSent,
        senderName: sender.name,
        receiverName: receiverUserData.name,
        messageType: MessageEnum.gif,
        messageId: messageId,
        messageReply: messageReply,
        caption: null,
      );
    } catch (e) {
      customSnackBar(e.toString(), context);
    }
  }

  Future<void> _saveContacts(
      UserModel senderData,
      UserModel receiverData,
      bool isText,
      message,
      DateTime timeSent,
      String receiverUid,
      String type) async {
    //first collection for receiver
    print('the type is: $isText');
    var receiverChatContact = ChatContactModel(
        name: senderData.name,
        profilePic: senderData.profilePic,
        contactId: senderData.uid,
        timeSent: timeSent,
        isOnlyText: isText,
        type: type,
        lastMessage: message);
    await firestore
        .collection('users')
        .doc(receiverUid)
        .collection('chats')
        .doc(senderData.uid)
        .set(receiverChatContact.toJson());
//second collection for sender
    var senderChatContact = ChatContactModel(
        name: receiverData.name,
        profilePic: receiverData.profilePic,
        contactId: receiverData.uid,
        timeSent: timeSent,
        isOnlyText: isText,
        type: type,
        lastMessage: message);
    await firestore
        .collection('users')
        .doc(senderData.uid)
        .collection('chats')
        .doc(receiverUid)
        .set(senderChatContact.toJson());
  }

  Future<void> _saveMessages({
    required String receiverUid,
    required String messageText,
    required DateTime timeSent,
    required String senderName,
    required String receiverName,
    required MessageEnum messageType,
    required String messageId,
    required MessageReply? messageReply,
    String? caption,
  }) async {
    var message = MessageModel(
        id: messageId,
        senderUid: auth.currentUser!.uid,
        receiverUid: receiverUid,
        messageText: messageText,
        messageType: messageType,
        timeSent: timeSent,
        messageReply: messageReply == null ? '' : messageReply.message,
        messageReplyType:
            messageReply == null ? MessageEnum.text : messageReply.messageType,
        repliedTo: messageReply == null
            ? ''
            : messageReply.isMe
                ? senderName
                : receiverName,
        caption: caption,
        isSeen: false);
    //for sender collection
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUid)
        .collection('messages')
        .doc(messageId)
        .set(message.toJson());
    //for receiver collection
    await firestore
        .collection('users')
        .doc(receiverUid)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .collection('messages')
        .doc(messageId)
        .set(message.toJson());
  }

  Stream<List<ChatContactModel>> get getChatContacts => firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .snapshots()
          .asyncMap((query) async {
        //async map to await and implement map method
        List<ChatContactModel> contacts = [];
        for (var doc in query.docs) {
          //parse data first
          var chatContact = ChatContactModel.fromJson(doc.data());
          //needed to pass user data beside to chat contact data
          var userData = await firestore
              .collection('users')
              .doc(chatContact.contactId)
              .get();
          user = UserModel.fromJson(userData.data()!);
          contacts.add(ChatContactModel(
            name: user!.name,
            profilePic: user!.profilePic,
            contactId: chatContact.contactId,
            timeSent: chatContact.timeSent,
            lastMessage: chatContact.lastMessage,
            isOnlyText: true,
            type: chatContact.type,
          ));
        }
        return contacts;
      });
  Stream<List<MessageModel>> getMessages(String receiverUid) => firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(receiverUid)
          .collection('messages')
          .orderBy('timeSent')
          .snapshots()
          .asyncMap((query) {
        List<MessageModel> messages = [];
        for (var val in query.docs) {
          var message = MessageModel.fromJson(val.data());
          messages.add(message);
        }
        return messages;
      });
  Future<void> sendFileMessage({
    required BuildContext context,
    required File file,
    required ProviderRef ref,
    required UserModel senderData,
    required MessageEnum fileType,
    required MessageReply? messageReply,
    String? caption,
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();
      String downloadUrl = await ref
          .read(firebaseStorageRepoProvider)
          .storeFileToFirebaseStorage(
            'chats/${fileType.type}/${senderData.uid}/${user!.uid}/$messageId',
            file,
          );
      String contactMessage;
      switch (fileType) {
        case MessageEnum.text:
          contactMessage = 'text';
          break;
        case MessageEnum.pdf:
          contactMessage = '🖨 pdf';
          break;
        case MessageEnum.audio:
          contactMessage = '🎵 audio';

          break;
        case MessageEnum.image:
          contactMessage = '📸 image';

          break;
        case MessageEnum.video:
          contactMessage = '📽 video';

          break;
        case MessageEnum.gif:
          contactMessage = 'GIF';
          break;
        default:
          contactMessage = 'text';
      }

      _saveContacts(
        senderData,
        user!,
        false,
        downloadUrl,
        timeSent,
        user!.uid,
        contactMessage,
      );
      _saveMessages(
          receiverUid: user!.uid,
          messageText: downloadUrl,
          timeSent: timeSent,
          senderName: senderData.name,
          receiverName: user!.name,
          messageType: fileType,
          messageId: messageId,
          messageReply: messageReply,
          caption: caption);
    } catch (e) {
      customSnackBar(e.toString(), context);
      print(e);
    }
  }

  void setMessageSeen(
    String messageId,
    BuildContext context,
    String receiverUid,
  ) async {
    try {
      //update field value isSeen
      //for sender collection
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(receiverUid)
          .collection('messages')
          .doc(messageId)
          .update({
        'isSeen': true,
      });

      //for receiver collection
      await firestore
          .collection('users')
          .doc(receiverUid)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .update({
        'isSeen': true,
      });
    } catch (e) {
      customSnackBar(e.toString(), context);
    }
  }
}

final chatRepoProvider = Provider(
  (ref) => ChatRepo(FirebaseAuth.instance, FirebaseFirestore.instance),
);

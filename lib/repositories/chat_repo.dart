// ignore_for_file: avoid_print, empty_catches

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:Lango/generated/l10n.dart';
import 'package:Lango/models/chat_contacts_model.dart';
import 'package:Lango/models/group_model.dart';
import 'package:Lango/models/message_model.dart';
import 'package:Lango/models/user_model.dart';
import 'package:Lango/shared/enums/message_enum.dart';
import 'package:Lango/shared/utils/functions.dart';

import '../controllers/message_reply_controller.dart';
import '../controllers/notification_controller.dart';
import '../shared/repos/firebase_storage_repo.dart';

class ChatRepo {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final ProviderRef ref;
  ChatRepo(this.auth, this.firestore, this.ref);
  UserModel? user;
  //send text message
  Future<void> sendTextMessage({
    required String messageText,
    required BuildContext context,
    required String receiverUid,
    required UserModel sender,
    required MessageReply? messageReply,
    required bool isGroupChat,
  }) async {
    var timeSent = DateTime.now();
    UserModel? receiverUserData;
    if (!isGroupChat) {
      var receiverData =
          await firestore.collection('users').doc(receiverUid).get();
      receiverUserData = UserModel.fromJson(receiverData.data()!);
    }
    // print('repo uid ${receiverUserData?.name}');
    // print(sender.name);
    // print(timeSent);
    _saveContacts(
      sender,
      receiverUserData,
      true,
      sender.phoneNumber,
      messageText,
      timeSent,
      receiverUid,
      isGroupChat,
      MessageEnum.text.type,
    );
    //to generate unique identifier
    var messageId = const Uuid().v1();
    _saveMessages(
      receiverUid: receiverUid,
      messageText: messageText,
      timeSent: timeSent,
      senderName: sender.name,
      receiverName: receiverUserData?.name,
      messageType: MessageEnum.text,
      messageId: messageId,
      messageReply: messageReply,
      isGroupChat: isGroupChat,
      caption: null,
    );
  }

  Future<void> sendNotification({
    required String body,
    required UserModel sender,
    required String receiverUid,
    required String token,
    required String title,
    required bool isGroupChat,
  }) async {
    ref.read(notificationControllerProvider).postMessageNotification(
      body: body,
      token: token,
      title: title,
      data: {
        'name': sender.name,
        'uid': sender.uid,
        'description': sender.description,
        'phoneNumber': sender.phoneNumber,
        'profilePic': sender.profilePic,
        'isOnline': sender.isOnline,
        'groupId': sender.groupId,
        'isGroupChat': isGroupChat
      },
    );
  }

  Future<void> sendGifMessage({
    required String gifUrl,
    required BuildContext context,
    required String receiverUid,
    required UserModel sender,
    required MessageReply? messageReply,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel? receiverUserData;

      if (!isGroupChat) {
        var receiverData =
            await firestore.collection('users').doc(receiverUid).get();
        receiverUserData = UserModel.fromJson(receiverData.data()!);
      }
      _saveContacts(
        sender,
        receiverUserData,
        false,
        sender.phoneNumber,
        gifUrl,
        timeSent,
        receiverUid,
        isGroupChat,
        MessageEnum.gif.type.toUpperCase(),
      );
      //to generate unique identifier
      var messageId = const Uuid().v1();
      _saveMessages(
          receiverUid: receiverUid,
          messageText: gifUrl,
          timeSent: timeSent,
          senderName: sender.name,
          receiverName: receiverUserData?.name,
          messageType: MessageEnum.gif,
          messageId: messageId,
          messageReply: messageReply,
          caption: null,
          isGroupChat: isGroupChat);
    } catch (e) {
      if (kDebugMode) {
        debugPrint(e.toString());
      }
      if (context.mounted) customSnackBar(e.toString(), context);
    }
  }

  Future<void> _saveContacts(
      UserModel senderData,
      UserModel? receiverData,
      bool isText,
      String phoneNumber,
      message,
      DateTime timeSent,
      String receiverUid,
      bool isGroupChat,
      String type) async {
    //first collection for receiver
    if (kDebugMode) {
      debugPrint('the type is: $isText');
    }
    if (isGroupChat) {
      await firestore.collection('groups').doc(receiverUid).update({
        'lastMessage': message,
        'timeSent': DateTime.now().millisecondsSinceEpoch,
        'lastMessageType': type,
      });
      return;
    }
    var receiverChatContact = ChatContactModel(
      name: senderData.name,
      profilePic: senderData.profilePic,
      contactId: senderData.uid,
      token: senderData.token,
      timeSent: timeSent,
      isOnlyText: isText,
      type: type,
      lastMessage: message,
      phoneNumber: phoneNumber,
    );
    await firestore
        .collection('users')
        .doc(receiverUid)
        .collection('chats')
        .doc(senderData.uid)
        .set(receiverChatContact.toJson());
//second collection for sender
    var senderChatContact = ChatContactModel(
        name: receiverData!.name,
        profilePic: receiverData.profilePic,
        contactId: receiverData.uid,
        timeSent: timeSent,
        token: receiverData.token,
        isOnlyText: isText,
        phoneNumber: phoneNumber,
        type: type,
        lastMessage: message);
    // print(senderChatContact);
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
    required String? receiverName,
    required MessageEnum messageType,
    required String messageId,
    required MessageReply? messageReply,
    String? caption,
    required bool isGroupChat,
  }) async {
    var message = MessageModel(
        id: messageId,
        senderUid: auth.currentUser!.uid,
        receiverUid: receiverUid,
        messageText: messageText,
        messageType: messageType,
        timeSent: timeSent,
        senderName: senderName,
        messageReply: messageReply == null ? '' : messageReply.message,
        messageReplyType:
            //default message reply type is text
            messageReply == null ? MessageEnum.text : messageReply.messageType,
        repliedTo: messageReply == null
            ? ''
            : messageReply.isMe
                ? senderName
                : receiverName ?? '',
        caption: caption,
        isSeen: false);
    //for sender collection
    if (isGroupChat) {
      await firestore
          .collection('groups')
          //reciever uid is groupId
          .doc(receiverUid)
          .collection('chats')
          .doc(messageId)
          .set(message.toJson());
      return;
    } else {
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(receiverUid)
          .collection('messages')
          .doc(messageId)
          .set(message.toJson());
      // log(message.toJson().toString());
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
  }

  Stream<List<ChatContactModel>> get getChatContacts => firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .orderBy('timeSent', descending: true)
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
          //sprint(user!.name);
          contacts.add(ChatContactModel(
            name: user!.name,
            profilePic: user!.profilePic,
            contactId: chatContact.contactId,
            timeSent: chatContact.timeSent,
            lastMessage: chatContact.lastMessage,
            token: chatContact.token,
            phoneNumber: user!.phoneNumber,
            isOnlyText: true,
            type: chatContact.type,
          ));
        }
        return contacts;
      });

  Stream<List<GroupModel>> get getChatGroups => firestore
          .collection('groups')
          .orderBy('timeSent', descending: true)
          .snapshots()
          .map((query) {
        List<GroupModel> groups = [];
        for (var doc in query.docs) {
          var group = GroupModel.fromJson(doc.data());
          if (group.membersUid.contains(auth.currentUser!.uid)) {
            groups.add(group);
          }
        }
        return groups;
      });

  Stream<List<MessageModel>> getMessages(String receiverUid) => firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(receiverUid)
          .collection('messages')
          .orderBy('timeSent', descending: false)
          .snapshots()
          .asyncMap((query) {
        List<MessageModel> messages = [];
        for (var val in query.docs) {
          var message = MessageModel.fromJson(val.data());
          messages.add(message);
        }
        return messages;
      });
  Stream<List<MessageModel>> getGroupMessages(String groupId) => firestore
          .collection('groups')
          .doc(groupId)
          .collection('chats')
          .orderBy('timeSent', descending: false)
          .snapshots()
          .map((query) {
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
    required String receiverUid,
    String? caption,
    required bool isGroupChat,
  }) async {
    var timeSent = DateTime.now();
    var messageId = const Uuid().v1();
    String downloadUrl =
        await ref.read(firebaseStorageRepoProvider).storeFileToFirebaseStorage(
              'chats/${fileType.type}/${senderData.uid}/${user!.uid}/$messageId',
              file,
            );
    print('url is $downloadUrl');
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

    UserModel? recieverUserData;
    if (!isGroupChat) {
      var userDataMap =
          await firestore.collection('users').doc(receiverUid).get();
      if (kDebugMode) {
        debugPrint('user data map is $userDataMap');
      }
      recieverUserData = UserModel.fromJson(userDataMap.data()!);
    }
    if (kDebugMode) {
      debugPrint('reciever user data is $recieverUserData');
    }
    _saveContacts(
      senderData,
      recieverUserData,
      false,
      senderData.phoneNumber,
      downloadUrl,
      timeSent,
      receiverUid,
      isGroupChat,
      contactMessage,
    );
    _saveMessages(
        receiverUid: receiverUid,
        messageText: downloadUrl,
        timeSent: timeSent,
        senderName: senderData.name,
        receiverName: recieverUserData?.name,
        messageType: fileType,
        messageId: messageId,
        messageReply: messageReply,
        isGroupChat: isGroupChat,
        caption: caption);
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
      if (context.mounted) customSnackBar(e.toString(), context);
    }
  }

  Future<void> deleteMessage(
    String messageId,
    BuildContext context,
    String receiverUid,
  ) async {
    try {
      //delete message in sender collection
      //for sender collection
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(receiverUid)
          .collection('messages')
          .doc(messageId)
          .delete();

      //for receiver collection
      await firestore
          .collection('users')
          .doc(receiverUid)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .delete();
      if (context.mounted) {
        customSnackBar(S.of(context).delete_snackbar, context);
      }
    } catch (e) {
      if (context.mounted) customSnackBar(e.toString(), context);
    }
  }

  void copyMessageToClipboard(String message, context) {
    try {
      Clipboard.setData(ClipboardData(text: message)).then((value) =>
          customSnackBar(S.of(context).copy_snackbar, context,
              color: getTheme(context).cardColor));
    } catch (e) {}
  }
}

final chatRepoProvider = Provider(
  (ref) => ChatRepo(FirebaseAuth.instance, FirebaseFirestore.instance, ref),
);

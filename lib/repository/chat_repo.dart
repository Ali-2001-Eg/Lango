import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/models/chat_contacts_model.dart';
import 'package:whatsapp_clone/models/message_model.dart';
import 'package:whatsapp_clone/models/user_model.dart';
import 'package:whatsapp_clone/shared/enums/message_enum.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';

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
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel receiverUserData;
      var receiverData =
          await firestore.collection('users').doc(receiverUid).get();
      receiverUserData = UserModel.fromJson(receiverData.data()!);
      _saveContacts(
          sender, receiverUserData, messageText, timeSent, receiverUid);
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
      );
    } catch (e) {
      customSnackBar(e.toString(), context);
    }
  }

  Future<void> _saveContacts(UserModel senderData, UserModel receiverData,
      String messageText, DateTime timeSent, String receiverUid) async {
    //first collection for receiver
    var receiverChatContact = ChatContactModel(
        name: senderData.name,
        profilePic: senderData.profilePic,
        contactId: senderData.uid,
        timeSent: timeSent,
        lastMessage: messageText);
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
        lastMessage: messageText);
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
  }) async {
    var message = MessageModel(
        id: messageId,
        senderUid: auth.currentUser!.uid,
        receiverUid: receiverUid,
        messageText: messageText,
        messageType: messageType,
        timeSent: timeSent,
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
          .snapshots()
          .asyncMap((query) {
        List<MessageModel> messages = [];
        for (var val in query.docs) {
          var message = MessageModel.fromJson(val.data());
          messages.add(message);
        }
        return messages;
      });
}

final chatRepoProvider = Provider(
  (ref) => ChatRepo(FirebaseAuth.instance, FirebaseFirestore.instance),
);

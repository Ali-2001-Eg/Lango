import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/models/group_model.dart';
import 'package:whatsapp_clone/shared/enums/message_enum.dart';
import 'package:whatsapp_clone/shared/repos/firebase_storage_repo.dart';
// ignore: unused_import
import 'package:whatsapp_clone/shared/widgets/select_contact_widget.dart';

final groupRepoProvider = Provider(
  (ref) => GroupRepo(
      auth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
      ref: ref),
);

class GroupRepo {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final ProviderRef ref;
  GroupRepo({
    required this.auth,
    required this.firestore,
    required this.ref,
  });

  void createGroup(
      String groupName, File groupPic, List<Contact> contacts) async {
    try {
      List<String> uids = [];
      for (int i = 0; i < contacts.length; i++) {
        var userData = await firestore
            .collection('users')
            .where('phoneNumber',
                isEqualTo: contacts[i].phones[0].number.replaceAll(' ', ''))
            .get();
        // log(userData.docs[0].data().toString());
        if (userData.docs.isNotEmpty && userData.docs[0].exists) {
          uids.add(userData.docs[0].data()['uid']);
        }
      }
      var groupId = const Uuid().v1();
      String pic = await ref
          .read(firebaseStorageRepoProvider)
          .storeFileToFirebaseStorage('groups/$groupId', groupPic);
      GroupModel groupModel = GroupModel(
        name: groupName,
        groupId: groupId,
        lastMessage: '',
        groupPic: pic,
        lastMessageType: MessageEnum.text,
        timeSent: DateTime.now(),
        senderId: auth.currentUser!.uid,
        membersUid: [auth.currentUser!.uid, ...uids],
      );
      await firestore
          .collection('groups')
          .doc(groupId)
          .set(groupModel.toJson());
    } catch (e) {
      print(e.toString());
    }
  }
}

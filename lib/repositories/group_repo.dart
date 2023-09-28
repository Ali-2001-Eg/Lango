// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/models/group_model.dart';
import 'package:whatsapp_clone/models/user_model.dart';
import 'package:whatsapp_clone/shared/enums/message_enum.dart';
import 'package:whatsapp_clone/shared/repos/firebase_storage_repo.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';
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
        log(userData.docs[0].data().toString());
        if (userData.docs.isNotEmpty && userData.docs[0].exists) {
          uids.add(userData.docs[0].data()['uid']);
        }
        log(uids.toString());
      }
      //to have non redaundant values
      var distinctUids = uids.toSet().toList();
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
        membersUid: [auth.currentUser!.uid, ...distinctUids],
      );
      await firestore
          .collection('groups')
          .doc(groupId)
          .set(groupModel.toJson());
      uids.forEach((element) async {
        await firestore.collection('users').doc(element).update({
          'groupId': FieldValue.arrayUnion([groupId])
        });
      });
    } catch (e) {}
  }

  Future<void> joinGroup(String groupId) async {
    var groupDoc = await firestore.collection('groups').doc(groupId).get();
    List users = groupDoc.data()!['membersUid'];
    if (!users.contains(auth.currentUser!.uid)) {
      print('join enters if statements');
      await firestore.collection('groups').doc(groupId).update({
        'membersUid': FieldValue.arrayUnion([auth.currentUser!.uid]),
      });

      await firestore.collection('users').doc(auth.currentUser!.uid).update({
        'groupId': FieldValue.arrayUnion([groupId])
      });
    }
  }

  Future<int> getAllGroupsNumbers() async {
    var groups = await firestore.collection('groups').get();
    return groups.docs.length;
  }

  Future<void> leaveGroup(String groupId) async {
    var groupDoc = await firestore.collection('groups').doc(groupId).get();
    List users = groupDoc.data()!['membersUid'];
    if (users.contains(auth.currentUser!.uid)) {
      print('leave enters if statements');

      await firestore.collection('groups').doc(groupId).update({
        'membersUid': FieldValue.arrayRemove([auth.currentUser!.uid]),
      });

      await firestore.collection('users').doc(auth.currentUser!.uid).update({
        'groupId': FieldValue.arrayRemove([groupId])
      });
    }
  }

  Stream<bool> isUserJoined(String groupId) =>
      firestore.collection('groups').doc(groupId).snapshots().map((query) =>
          query.data()!['membersUid'].contains(auth.currentUser!.uid));

  Stream searchByName(String searchText) {
    return firestore
        .collection('groups')
        .where('name', isGreaterThanOrEqualTo: searchText)
        .snapshots();
  }

  Future<List<UserModel>> getGroupMembers(String groupId) async {
    var groupDoc = await firestore.collection('groups').doc(groupId).get();
    List members = groupDoc.data()!['membersUid'];
    List<UserModel> groupMembers = [];
    UserModel user;
    for (int i = 0; i < members.length; i++) {
      var userData = await firestore
          .collection('users')
          .where('uid', isEqualTo: members[i])
          .get();
      if (userData.docs.isNotEmpty && userData.docs[0].exists) {
        user = UserModel.fromJson(userData.docs[0].data());
        groupMembers.add(user);
      }
    }
    return groupMembers;
  }

  Stream<List<GroupModel>> getAllGroups() {
    List<GroupModel> groups = [];
    return firestore.collection('groups').snapshots().map((query) {
      for (var element in query.docs) {
        groups.add(GroupModel.fromJson(element.data()));
      }
      return groups;
    });
  }
}

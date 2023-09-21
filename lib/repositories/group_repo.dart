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
      uids.forEach((element) async {
        await firestore.collection('users').doc(element).update({
          'groupId': FieldValue.arrayUnion([groupId])
        });
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> toggleGroupJoin(String groupId) async {
    var userDoc =
        await firestore.collection('users').doc(auth.currentUser!.uid).get();
    List groupIds = userDoc['groupId'];
    print('condition ${groupIds.contains(groupId)}');
    if (groupIds.contains(groupId)) {
      //for group collection
      await firestore.collection('groups').doc(groupId).update({
        'membersUid': FieldValue.arrayRemove([auth.currentUser!.uid]),
      });
      //for user collection
      await firestore.collection('users').doc(auth.currentUser!.uid).update({
        'groupId': FieldValue.arrayRemove([groupId])
      });
    } else {
      //for leaving group
      await firestore.collection('groups').doc(groupId).update({
        'membersUid': FieldValue.arrayUnion([auth.currentUser!.uid]),
      });

      await firestore.collection('users').doc(auth.currentUser!.uid).update({
        'groupId': FieldValue.arrayUnion([groupId])
      });
    }
  }

  Future<bool> isUserJoined(String groupId) async {
    var userDoc =
        await firestore.collection('users').doc(auth.currentUser!.uid).get();
    List groupIds = userDoc.data()!['groupId'];
    if (groupIds.contains(groupId)) {
      return true;
    } else {
      return false;
    }
  }

  List<GroupModel>? _searchedGroups;
  List<GroupModel> get searchedGroups => _searchedGroups!;
  Stream<List<GroupModel>> searchByName(String searchText) {
    print('Ali');
    return firestore
        .collection('groups')
        .where('name', isGreaterThan: searchText)
        .snapshots()
        .map((event) {
      _searchedGroups = [];
      for (var element in event.docs) {
        _searchedGroups!.add(GroupModel.fromJson(element.data()));
      }
      return _searchedGroups!;
    });
  }

  Future<List<UserModel>> getGroupMembers(String groupId) async {
    print('ali');
    var groupDoc = await firestore.collection('groups').doc(groupId).get();
    List members = groupDoc.data()!['membersUid'];
    print('members are $members');
    List<UserModel> groupMembers = [];
    UserModel user;
    for (int i = 0; i < members.length; i++) {
      var userData = await firestore
          .collection('users')
          .where('uid', isEqualTo: members[i])
          .get();
      print(userData.docs.isNotEmpty && userData.docs[0].exists);
      if (userData.docs.isNotEmpty && userData.docs[0].exists) {
        user = UserModel.fromJson(userData.docs[0].data());
        groupMembers.add(user);
      }
    }
    print('groupMembers are ${groupMembers.length} members');
    return groupMembers;
  }
}

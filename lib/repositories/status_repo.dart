// import 'dart:developer';
// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:Lango/models/status_model.dart';
import 'package:Lango/models/user_model.dart';
import 'package:Lango/shared/enums/message_enum.dart';
import 'package:Lango/shared/repos/firebase_storage_repo.dart';

class StatusRepo extends ChangeNotifier {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final ProviderRef ref;

  StatusRepo(this.firestore, this.auth, this.ref);

  void uploadStatus({
    required String username,
    required String profilePic,
    required String phoneNumber,
    required BuildContext context,
    required MessageEnum type,
    File? statusMedia,
    String? statusText,
  }) async {
    try {
      ref.read(loadingProvider.state).update((state) => true);

      String statusId = const Uuid().v1();
      String uid = auth.currentUser!.uid;
      String status;
      if (statusText == null) {
        status = await ref
            .read(firebaseStorageRepoProvider)
            .storeFileToFirebaseStorage(
                'status/${type.type}/$statusId/$uid', statusMedia!);
      } else {
        status = statusText;
      }
      List<Contact> contacts = [];
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
      Set<String> audience = {uid};

      //we will get all contacts data
      for (int i = 0; i < contacts.length - 1; i++) {
        debugPrint(contacts[i].displayName);
        if (contacts[i].phones.isEmpty) {
          //for any problem in contact list
          continue;
        }
        debugPrint(contacts[i].phones[0].number);
        var userData = await firestore.collection('users').get();
        if (userData.docs.isNotEmpty) {
          UserModel userModel;
          for (var element in userData.docs) {
            userModel = UserModel.fromJson(element.data());
            // debugPrint('phone number ${userModel.phoneNumber}');
            if (contacts[i]
                .phones[0]
                .normalizedNumber
                .replaceAll(' ', '')
                .contains(userModel.phoneNumber)) {
              audience.add(userModel.uid);
              // debugPrint('audience $audience');
            }
          }
        }
      }

      var statusModel = StatusModel(
        uid: uid,
        username: username,
        phoneNumber: phoneNumber,
        status: status,
        createdAt: DateTime.now(),
        profilePic: profilePic,
        statusId: statusId,
        audience: audience.toList(),
        type: type,
      );
      await firestore
          .collection('status')
          .doc(statusId)
          .set(statusModel.toJson());
      // debugPrint('status is  ${statusModel.toString()}');
      ref.read(loadingProvider.state).update((state) => false);
      notifyListeners();
    } catch (e) {
      ref.read(loadingProvider.state).update((state) => false);
      notifyListeners();
      // customSnackBar(e.toString(), context);
    }
  }

  //get status
  Stream<List<List<StatusModel>>> getStatus() => firestore
          //must enable index for that query
          .collection('status')
          .where('audience', arrayContains: auth.currentUser!.uid)
          .where(
            'createdAt',
            isGreaterThan: DateTime.now()
                .subtract(const Duration(hours: 24))
                .millisecondsSinceEpoch,
          )
          .snapshots()
          .map((query) {
        List<StatusModel> status = [];
        Map<String, List<StatusModel>> groupedStatuses = {};
        List<List<StatusModel>> groupedStatusList = [];
        for (var element in query.docs) {
          status.add(StatusModel.fromJson(element.data()));
        }
        for (var object in status) {
          var key = object.username;
          //debugPrint('uid: ' + key);
          if (groupedStatuses.containsKey(key)) {
            groupedStatuses[key]!.add(object);
          } else {
            groupedStatuses[key] = [object];
          }
        }
        groupedStatusList = groupedStatuses.values.toList();

        //debugPrint(  'grouped list is ${groupedStatusList.map((e) => e.map((e) => e.statusId).toList())}');
        //debugPrint('status list length ${groupedStatusList.length}');
        return groupedStatusList;
      });
}

final statusRepoProvider = Provider((ref) =>
    StatusRepo(FirebaseFirestore.instance, FirebaseAuth.instance, ref));

final loadingProvider = StateProvider<bool>((ref) => false);

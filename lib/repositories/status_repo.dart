// import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/models/status_model.dart';
import 'package:whatsapp_clone/models/user_model.dart';
import 'package:whatsapp_clone/shared/enums/message_enum.dart';
import 'package:whatsapp_clone/shared/repos/firebase_storage_repo.dart';

import '../shared/utils/functions.dart';

class StatusRepo {
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
      List<String> audience = [];
      for (int i = 0; i < contacts.length; i++) {
        //we will get all contacts data
        // log(contacts[i].name.first);
        var userData = await firestore
            .collection('users')
            .where(
              'phoneNumber',
              isEqualTo: contacts[i].phones[0].number.replaceAll(' ', ''),
            )
            .get();
        if (userData.docs.isNotEmpty) {
          var userModel = UserModel.fromJson(userData.docs[0].data());
          audience.add(userModel.uid);
          var statusModel = StatusModel(
            uid: uid,
            username: username,
            phoneNumber: phoneNumber,
            status: status,
            createdAt: DateTime.now(),
            profilePic: profilePic,
            statusId: statusId,
            audience: audience,
            type: type,
          );
          await firestore
              .collection('users')
              .doc(userModel.uid)
              .collection('status')
              .doc(statusId)
              .set(statusModel.toJson());
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
        audience: audience,
        type: type,
      );
      await firestore
          .collection('users')
          .doc(uid)
          .collection('status')
          .doc(statusId)
          .set(statusModel.toJson());
      // print(statusModel.statusId);
    } catch (e) {
      print('Error while \${e.toString()}');
      // customSnackBar(e.toString(), context);
    }
  }

  //get status
  Future<List<StatusModel>> getStatus() async {
    List<StatusModel> statusData = [];
    try {
      var snapshot = await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('status')
          .where(
            'createdAt',
            isGreaterThan: DateTime.now()
                .subtract(const Duration(days: 1))
                .millisecondsSinceEpoch,
          )
          .get();
      for (var query in snapshot.docs) {
        StatusModel status = StatusModel.fromJson(query.data());
        statusData.add(status);
      }
      return statusData;
    } catch (e) {
      print('Error while $e');
      return statusData;
    }
  }
}

final statusRepoProvider = Provider((ref) =>
    StatusRepo(FirebaseFirestore.instance, FirebaseAuth.instance, ref));

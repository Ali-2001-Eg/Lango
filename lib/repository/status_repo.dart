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

  void uploadStatusFile({
    required String username,
    required String profilePic,
    required String phoneNumber,
    required File statusMedia,
    required BuildContext context,
    required MessageEnum type,
  }) async {
    try {
      String statusId = const Uuid().v1();
      String uid = auth.currentUser!.uid;
      var fileUrl = await ref
          .read(firebaseStorageRepoProvider)
          .storeFileToFirebaseStorage(
              'status/$type/$statusId/$uid', statusMedia);
      List<Contact> contacts = [];
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
      List<String> audience = [];
      for (int i = 0; i < contacts.length; i++) {
        //we will get all contacts data
        var userData = await firestore
            .collection('users')
            .where('phoneNumber',
                isEqualTo: contacts[i].phones[0].number.replaceAll(' ', ''))
            .get();
        if (userData.docs.isNotEmpty) {
          var userModel = UserModel.fromJson(userData.docs[0].data());
          audience.add(userModel.uid);
        }
      }
      List<String> statusFileUrls = [];
      var statusSnapshot = await firestore
          .collection('status')
          .where('uid', isEqualTo: auth.currentUser!.uid)
          .where('createdAt', //created only one day ago
              isLessThan: DateTime.now().subtract(const Duration(hours: 24)))
          .get();
      if (statusSnapshot.docs.isNotEmpty) {
        StatusModel status =
            StatusModel.fromJson(statusSnapshot.docs[0].data());
        statusFileUrls = status.fileUrls;
        statusFileUrls.add(fileUrl);
        await firestore
            .collection('status')
            .doc(statusSnapshot.docs[0].id)
            .update({
          'photoUrls': statusFileUrls,
        });
        return;
      } else {
        statusFileUrls = [fileUrl];
      }
      var statusModel = StatusModel(
        uid: uid,
        username: username,
        phoneNumber: phoneNumber,
        fileUrls: statusFileUrls,
        createdAt: DateTime.now(),
        profilePic: profilePic,
        statusId: statusId,
        audience: audience,
        type: type,
      );
      await firestore
          .collection('status')
          .doc(statusId)
          .set(statusModel.toJson());
      print(statusModel.statusId);
    } catch (e) {
      print('Error while uploading${e.toString()}');
      // customSunackBar(e.toString(), context);
    }
  }
}

final statusRepoProvider = Provider((ref) =>
    StatusRepo(FirebaseFirestore.instance, FirebaseAuth.instance, ref));

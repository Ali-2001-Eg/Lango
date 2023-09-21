// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';

final profileRepoProvider = Provider(
  (ref) => ProfileRepo(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
  ),
);

class ProfileRepo {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  ProfileRepo({
    required this.auth,
    required this.firestore,
    required this.storage,
  });
  UserModel? user;
  Future<UserModel> getProfileData() async {
    var userDoc =
        await firestore.collection('users').doc(auth.currentUser!.uid).get();
    user = UserModel.fromJson(userDoc.data()!);
    return user!;
  }

  Future<void> updateName({
    String? newUsername,
  }) async {
    await firestore.collection('users').doc(auth.currentUser!.uid).update({
      'name': newUsername,
    });
  }

  Future<void> updateDescription({
    String? newDescription,
  }) async {
    await firestore.collection('users').doc(auth.currentUser!.uid).update({
      'description': newDescription,
    });
  }

  Future<void> updatePhoneNumber({
    String? newPhonNumber,
  }) async {
    await firestore.collection('users').doc(auth.currentUser!.uid).update({
      'phoneNumber': newPhonNumber,
    });
  }

  Future<void> updateProfilePic({String? newProfilePic}) async {
    TaskSnapshot snap = await storage
        .ref()
        .child(auth.currentUser!.uid)
        .child(newProfilePic!)
        .putFile(File(newProfilePic));
    String downloadUrl = await snap.ref.getDownloadURL();
    await firestore.collection('users').doc(auth.currentUser!.uid).update({
      'profilePic': downloadUrl,
    });
  }
}

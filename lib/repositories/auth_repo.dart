// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/models/user_model.dart';
import 'package:whatsapp_clone/repositories/firebase_notification_repo.dart';
import 'package:whatsapp_clone/screens/auth/otp_screen.dart';
import 'package:whatsapp_clone/screens/auth/user_info.dart';
import 'package:whatsapp_clone/screens/home_screen.dart';
import 'package:whatsapp_clone/shared/repos/firebase_storage_repo.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';

class AuthRepo {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepo({required this.auth, required this.firestore});

  Future<void> signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
        },
        verificationFailed: (e) {
          throw Exception(e.message);
        },
        codeSent: ((String verificationId, int? resendToken) async {
          Navigator.pushNamed(
            context,
            OtpScreen.routeName,
            arguments: verificationId,
          );
        }),
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      customSnackBar(e.message!, context);
    }
  }

  Future<void> verifyOtp(BuildContext context, String verificationId,
      String otpSubmittedFromUser) async {
    try {
      //to create our own credentials
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpSubmittedFromUser,
      );
      await auth.signInWithCredential(credential);
      Navigator.pushNamedAndRemoveUntil(
        context,
        UserInfoScreen.routeName,
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      customSnackBar(e.message!, context);
    }
  }

  Future<void> saveDataToFireStore(
      {required String name,
      required File? profilePic,
      required ProviderRef ref,
      required String description,
      required BuildContext context}) async {
    try {
      String uid = auth.currentUser!.uid;
      String photoUrl =
          'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png';
      if (profilePic != null) {
        photoUrl = await ref
            .read<FirebaseStorageRepo>(firebaseStorageRepoProvider)
            .storeFileToFirebaseStorage('profilePic/$uid', profilePic);
      }

      UserModel user = UserModel(
        name: name,
        uid: uid,
        description: description,
        profilePic: photoUrl,
        phoneNumber: auth.currentUser!.phoneNumber!,
        isOnline: true,
        token: (await ref.read(firebaseMessagingRepoProvider).loadToken()),
        groupId: [],
      );
      await firestore.collection('users').doc(uid).set(user.toJson());
      Navigator.pushNamedAndRemoveUntil(
          context, HomeScreen.routeName, (route) => false);
    } catch (e) {
      customSnackBar(e.toString(), context);
    }
  }

//to get user data and to know if user has registered or not to redirect an appropriate page to him
  Future<UserModel?> get getUSerData async {
    UserModel? user;
    var userData =
        await firestore.collection('users').doc(auth.currentUser?.uid).get();
    if (userData.data() != null) {
      user = UserModel.fromJson(userData.data()!);
    }
    return user;
  }

  Stream<UserModel> userData(String uid) {
    return firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((query) => UserModel.fromJson(query.data()!));
  }

  Future<String> getUsername(String uid) async {
    var senderName = await firestore.collection('users').doc(uid).get();

    final username = senderName.data()?['username'];

    if (username == null) {}

    return username;
  }

  Future<void> setUserState(bool isOnline) async {
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({'isOnline': isOnline});
  }
}

// to get provide
//ref allows us to interact with other providers with dependency injection
final authRepositoryProvider = Provider(
  (ref) => AuthRepo(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  ),
);

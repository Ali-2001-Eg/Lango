// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:Lango/repositories/status_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:Lango/models/user_model.dart';
import 'package:Lango/repositories/firebase_notification_repo.dart';
import 'package:Lango/screens/auth/otp_screen.dart';
import 'package:Lango/screens/auth/user_info.dart';
import 'package:Lango/screens/home_screen.dart';
import 'package:Lango/shared/repos/firebase_storage_repo.dart';
import 'package:Lango/shared/utils/functions.dart';

class AuthRepo {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final ProviderRef ref;
  AuthRepo({
    required this.auth,
    required this.firestore,
    required this.ref,
  });

  Future<void> signInWithPhone(BuildContext context, String phoneNumber) async {
    ref.read(loadingProvider.notifier).update((state) => true);
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
        },
        verificationFailed: (e) {
          customSnackBar(e.message!, context);
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
      // await Future.delayed(
      //   const Duration(seconds: 3),
      // );
      ref.read(loadingProvider.notifier).update((state) => false);
    } on FirebaseAuthException catch (e) {
      customSnackBar(e.message!, context);
      ref.read(loadingProvider.notifier).update((state) => false);
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
      var user =
          await firestore.collection('users').doc(auth.currentUser!.uid).get();
      if (user.exists) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          HomeScreen.routeName,
          (route) => false,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          UserInfoScreen.routeName,
          (route) => false,
        );
      }
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
        token: (await ref
            .read(firebaseMessagingRepoProvider)
            .firebaseMessaging
            .getToken())!,
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
  Stream<UserModel?> get getUserData {
    return firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .snapshots()
        .map((event) {
      UserModel? user;
      if (event.data() != null) {
        user = UserModel.fromJson(event.data()!);
      }
      return user;
    });
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

  Future<void> signOut() async {
    await auth.signOut();
  }
}

// to get provide
//ref allows us to interact with other providers with dependency injection
final authRepositoryProvider = Provider(
  (ref) => AuthRepo(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
    ref: ref,
  ),
);

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/controllers/auth_controller.dart';
import '../models/call_model.dart';
import '../repositories/call_repo.dart';

final callControllerProvider = Provider((ref) {
  final callController = ref.read(callRepoProvider);
  return CallController(
      ref: ref, callRepo: callController, auth: FirebaseAuth.instance);
});

class CallController {
  final ProviderRef ref;
  final CallRepo callRepo;
  final FirebaseAuth auth;
  CallController({
    required this.ref,
    required this.callRepo,
    required this.auth,
  });
  void call(
    String receiverName,
    String receiverProfilePic,
    bool isGroupChat,
    String receiverUid,
    BuildContext context,
  ) {
    ref.read(userDataProvider).whenData((value) {
      var callId = const Uuid().v1();
      CallModel callerData = CallModel(
        callerId: auth.currentUser!.uid,
        callerName: value!.name,
        receiverId: receiverUid,
        receiverName: receiverName,
        callerPic: value.profilePic,
        receiverPic: receiverProfilePic,
        callId: callId,
        hasDialled: true,
      );
      CallModel receiverData = CallModel(
        callerId: auth.currentUser!.uid,
        callerName: value.name,
        receiverId: receiverUid,
        receiverName: receiverName,
        callerPic: value.profilePic,
        receiverPic: receiverProfilePic,
        callId: callId,
        hasDialled: false, //default
      );
      //using callabale class
      isGroupChat
          ? callRepo.makeGroupCall(callerData, context, receiverData)
          : callRepo(callerData, receiverData, context);
    });
  }

  Stream<DocumentSnapshot> get chatStream => callRepo.callStream;
  void endCall({
    required String callerId,
    required String receiverId,
    required BuildContext context,
    required bool isGroupChat,
  }) =>
      isGroupChat
          ? callRepo.endGroupCall(callerId, receiverId, context)
          : callRepo.endCall(callerId, receiverId, context);
}

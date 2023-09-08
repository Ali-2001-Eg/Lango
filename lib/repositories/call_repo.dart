// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/models/call_model.dart';
import 'package:whatsapp_clone/models/group_model.dart';
import 'package:whatsapp_clone/screens/call/call_screen.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';

final callRepoProvider = Provider(
  (ref) => CallRepo(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  ),
);

class CallRepo {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  CallRepo({
    required this.auth,
    required this.firestore,
  });

  void call(
    CallModel callerData,
    CallModel receiverData,
    BuildContext context,
  ) async {
    try {
      await firestore
          .collection('calls')
          .doc(callerData.callerId)
          .set(callerData.tojson());
      await firestore
          .collection('calls')
          .doc(callerData.receiverId)
          .set(receiverData.tojson());
      navTo(
          context,
          CallScreen(
            channelId: callerData.callId,
            callData: callerData,
            isGroupChat: false,
          ));
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      customSnackBar(e.toString(), context);
    }
  }

  Stream<DocumentSnapshot> get callStream =>
      firestore.collection('calls').doc(auth.currentUser!.uid).snapshots();

  void endCall(
    String callerId,
    String receiverId,
    BuildContext context,
  ) async {
    try {
      await firestore.collection('calls').doc(callerId).delete();
      await firestore.collection('calls').doc(receiverId).delete();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      customSnackBar(e.toString(), context);
    }
  }

  void makeGroupCall(
    CallModel senderCallData,
    BuildContext context,
    CallModel receiverCallData,
  ) async {
    try {
      await firestore
          .collection('calls')
          .doc(senderCallData.callerId)
          .set(senderCallData.tojson());

      var groupSnapshot = await firestore
          .collection('groups')
          .doc(senderCallData.receiverId)
          .get();
      GroupModel group = GroupModel.fromJson(groupSnapshot.data()!);
      if (kDebugMode) {
        print('members uid list is ${group.membersUid.length}');
      }
      for (var id in group.membersUid) {
        await firestore
            .collection('calls')
            .doc(id)
            .set(receiverCallData.tojson());
      }

      navTo(
          context,
          CallScreen(
            channelId: senderCallData.callId,
            callData: senderCallData,
            isGroupChat: true,
          ));
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      customSnackBar(e.toString(), context);
    }
  }

  void endGroupCall(
    String callerId,
    String receiverId,
    BuildContext context,
  ) async {
    try {
      await firestore.collection('calls').doc(callerId).delete();
      var groupSnapshot =
          await firestore.collection('groups').doc(receiverId).get();
      GroupModel group = GroupModel.fromJson(groupSnapshot.data()!);
      for (var id in group.membersUid) {
        await firestore.collection('calls').doc(id).delete();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      customSnackBar(e.toString(), context);
    }
  }
}

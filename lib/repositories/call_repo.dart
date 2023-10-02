// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/controllers/notification_controller.dart';
import 'package:whatsapp_clone/models/call_model.dart';
import 'package:whatsapp_clone/models/group_model.dart';
import 'package:whatsapp_clone/screens/call/call_screen.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';

final callRepoProvider = Provider(
  (ref) => CallRepo(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
    ref: ref,
  ),
);

class CallRepo {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final ProviderRef ref;
  CallRepo({
    required this.auth,
    required this.firestore,
    required this.ref,
  });

  void call(
    CallModel callerData,
    CallModel receiverData,
    BuildContext context,
    String callerToken,
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
      _saveCallHistory(receiverData, callerToken);
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
    CallModel call,
  ) async {
    try {
      await firestore.collection('calls').doc(callerId).delete();
      await firestore.collection('calls').doc(receiverId).delete();
      //_saveCallHistory(call);
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
    CallModel call,
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
      //_saveCallHistory(call);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      customSnackBar(e.toString(), context);
    }
  }

 

  void _saveCallHistory(CallModel call, String callerToken) async {
    //for caller
    await firestore
        .collection('users')
        .doc(call.callerId)
        .collection('callHistory')
        .doc(call.callId)
        .set({
      'callerName': call.callerName,
      'receiverName': call.receiverName,
      'callerPic': call.callerPic,
      'recieverPic': call.receiverPic,
      'hasDialled': call.hasDialled,
      'callerUid': call.callerId,
      'receiverUid': call.receiverId,
      'callerToken': callerToken,
      'recieverToken': call.token,
      'timeSent': DateTime.now().microsecondsSinceEpoch,
    });
    //for reciever
    await firestore
        .collection('users')
        .doc(call.receiverId)
        .collection('callHistory')
        .doc(call.callId)
        .set({
      'callerName': call.callerName,
      'receiverName': call.receiverName,
      'callerPic': call.callerPic,
      'recieverPic': call.receiverPic,
      'hasDialled': call.hasDialled,
      'callerUid': call.callerId,
      'receiverUid': call.receiverId,
      'callerToken': callerToken,
      'recieverToken': call.token,
      'timeSent': DateTime.now().microsecondsSinceEpoch,
    });
  }

  Stream<List<Map<String, dynamic>>> getCallHistory() => firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('callHistory')
          .snapshots()
          .map((query) {
        List<Map<String, dynamic>> callHistory = [];
        query.docs.forEach((element) {
          if (element.data().isNotEmpty) {
            callHistory.add(element.data());
          }
        });
        return callHistory;
      });
}

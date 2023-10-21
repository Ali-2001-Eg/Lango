import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Chat_Live/generated/l10n.dart';
import 'package:Chat_Live/models/user_model.dart';
import 'package:Chat_Live/screens/chat/chat_screen.dart';
import 'package:Chat_Live/shared/utils/functions.dart';

class ContactRepo {
  final FirebaseFirestore firestore;

  ContactRepo(this.firestore);

  Future<List<Contact>> get getContacts async {
    List<Contact> contacts = [];
    try {
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return contacts;
  }

  Future<void> selectContact(
      Contact selectedContact, BuildContext context) async {
    try {
      var userCollection = await firestore.collection('users').get();
      for (var doc in userCollection.docs) {
        var userData = UserModel.fromJson(doc.data());
        String selectedPhoneNum =
            selectedContact.phones[0].normalizedNumber.replaceAll(' ', '');
        /* if (!selectedPhoneNum.startsWith('+2')) {
          selectedPhoneNum = '+2$selectedPhoneNum';
        } */
        if (kDebugMode) {
          print(selectedPhoneNum);
        }
        /*  if (kDebugMode) {
          print(userData.phoneNumber);
        } */
        if (selectedPhoneNum == userData.phoneNumber && context.mounted) {
          Navigator.pushNamed(
            context,
            ChatScreen.routeName,
            arguments: {
              'name': userData.name,
              'uid': userData.uid,
              'description': userData.description,
              'phoneNumber': userData.phoneNumber,
              'profilePic': userData.profilePic,
              'isOnline': userData.isOnline,
              'groupId': userData.groupId,
              'isGroupChat': false,
              'token': userData.token,
            },
          );
        } else {
          customSnackBar(S.of(context).non_register_user, context);
        }
      }
    } catch (e) {
      customSnackBar(e.toString(), context);
    }
  }
}

final selectContactRepoProvider = Provider(
  (ref) => ContactRepo(FirebaseFirestore.instance),
);

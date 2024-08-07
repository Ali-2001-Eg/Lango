import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirebaseStorageRepo {
  final FirebaseStorage storage;

  FirebaseStorageRepo(this.storage);

  Future<String> storeFileToFirebaseStorage(String ref, File file) async {
    TaskSnapshot snap = await storage.ref().child(ref).putFile(file);
    String downloadUrl = await snap.ref.getDownloadURL();
    print('repo url is $downloadUrl');

    return downloadUrl;
  }
}

final firebaseStorageRepoProvider = Provider(
  (ref) => FirebaseStorageRepo(FirebaseStorage.instance),
);

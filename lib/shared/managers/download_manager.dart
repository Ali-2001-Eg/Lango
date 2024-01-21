import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:Lango/shared/utils/functions.dart';

import '../enums/message_enum.dart';

final downloadManagerProvider =
    Provider((ref) => DownloadManager(FirebaseStorage.instance));

class DownloadManager {
  final FirebaseStorage storage;
  DownloadManager(this.storage);
  Future<void> downloadFile(
      {required String fileUrl,
      required MessageEnum fileType,
      //required String fileExtension,
      required BuildContext context}) async {
    try {
      final dio = Dio();

      PermissionStatus permissionStatus = PermissionStatus.granted;
      if (permissionStatus.isGranted) {
        Directory? dir = await getExternalStorageDirectory();
        final fileName = fileUrl.substring(fileUrl.lastIndexOf('/') + 1);
        String fileExtension;
        switch (fileType) {
          case MessageEnum.text:
            fileExtension = 'txt';
            break;
          case MessageEnum.audio:
            fileExtension = 'mp3';
            break;
          case MessageEnum.image:
            fileExtension = 'jpeg';
            break;
          case MessageEnum.video:
            fileExtension = 'mp4';
            break;
          case MessageEnum.pdf:
            fileExtension = 'pdf';
            break;
          case MessageEnum.gif:
            fileExtension = 'gif';
            break;
        }
        String pathToSave = '${dir!.path}/$fileName.$fileExtension';
        final response = await dio.download(fileUrl, pathToSave);
        if (kDebugMode) {
          debugPrint('status code is ${response.statusCode}');
        } // Check the status code
        if (kDebugMode) {
          debugPrint('status message${response.statusMessage!}');
        } // Check the status message
        if (kDebugMode) {
          debugPrint('File saved at: $pathToSave');
        }
      } else if (permissionStatus.isDenied && context.mounted) {
        if (kDebugMode) {
          debugPrint('permission denied');
        }
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
                'Please grant storage permission to download files.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) customSnackBar(e.toString(), context);
      // debugPrint(e.toString());
    }
  }
}

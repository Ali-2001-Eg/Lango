import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/controllers/auth_controller.dart';
import 'package:whatsapp_clone/repository/status_repo.dart';
import '../shared/enums/message_enum.dart';

class StatusController {
  final StatusRepo statusRepo;
  final ProviderRef ref;

  StatusController(this.statusRepo, this.ref);

  void addFileStatus({
    required MessageEnum type,
    required BuildContext context,
    required File statusMedia,
  }) {
    ref.watch(userDataProvider).whenData((value) => statusRepo.uploadStatusFile(
          username: value!.name,
          profilePic: value.profilePic,
          phoneNumber: value.phoneNumber,
          statusMedia: statusMedia,
          context: context,
          type: type,
        ));
  }
}

final statusControllerProvider = Provider((ref) {
  final statusRepo = ref.read(statusRepoProvider);
  return StatusController(statusRepo, ref);
});

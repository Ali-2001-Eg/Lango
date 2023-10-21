import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Chat_Live/controllers/auth_controller.dart';
import 'package:Chat_Live/repositories/status_repo.dart';
import '../models/status_model.dart';
import '../shared/enums/message_enum.dart';

class StatusController {
  final StatusRepo statusRepo;
  final ProviderRef ref;

  StatusController(this.statusRepo, this.ref);

  void shareStatus({
    required MessageEnum type,
    required BuildContext context,
    File? statusMedia,
    String? statusText,
  }) {
    ref.watch(userDataProvider).whenData((value) => statusRepo.uploadStatus(
        username: value!.name,
        profilePic: value.profilePic,
        phoneNumber: value.phoneNumber,
        statusMedia: statusMedia,
        context: context,
        type: type,
        statusText: statusText));
  }

  Stream<List<List<StatusModel>>> get status => statusRepo.getStatus();
}

final statusControllerProvider = Provider((ref) {
  final statusRepo = ref.read(statusRepoProvider);
  return StatusController(statusRepo, ref);
});

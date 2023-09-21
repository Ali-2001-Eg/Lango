import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/repositories/group_repo.dart';

import '../models/group_model.dart';
import '../models/user_model.dart';

final groupControllerProvider = Provider((ref) {
  final groupRepo = ref.read(groupRepoProvider);
  return GroupController(ref: ref, groupRepo: groupRepo);
});

class GroupController {
  final ProviderRef ref;
  final GroupRepo groupRepo;

  GroupController({required this.ref, required this.groupRepo});
  void createGroup(String groupName, File groupPic, List<Contact> contacts) =>
      groupRepo.createGroup(groupName, groupPic, contacts);

  void toggleGroupJoin(String groupId) => groupRepo.toggleGroupJoin(groupId);

  Future<bool> isUserJoined(String groupId) => groupRepo.isUserJoined(groupId);

  Stream<List<GroupModel>> searchByName(String groupName) =>
      groupRepo.searchByName(groupName);

  Future<List<UserModel>> getGroupMembers(String groupId) =>
      groupRepo.getGroupMembers(groupId);

  List<GroupModel> get searchedGroupsList => groupRepo.searchedGroups;
}

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Chat_Live/repositories/group_repo.dart';

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

  Future<void> joinGroup(String groupId) async =>
      await groupRepo.joinGroup(groupId);

  Future<void> leaveGroup(String groupId) async =>
      await groupRepo.leaveGroup(groupId);

  Stream<bool> isUserJoined(String groupId) => groupRepo.isUserJoined(groupId);

  Stream searchByName(String groupName) => groupRepo.searchByName(groupName);

  Future<List<UserModel>> getGroupMembers(String groupId) =>
      groupRepo.getGroupMembers(groupId);

  Stream<List<GroupModel>> get groups => groupRepo.getAllGroups();
  Future<int> get getGroupsCount => groupRepo.getAllGroupsNumbers();
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Lango/models/user_model.dart';

import 'package:Lango/repositories/profile_repo.dart';

final profileControllerProvider = Provider(
  (ref) {
    final profileRepo = ref.read(profileRepoProvider);
    return ProfileController(profileRepo: profileRepo, ref: ref);
  },
);

class ProfileController {
  final ProfileRepo profileRepo;
  final ProviderRef ref;
  ProfileController({
    required this.profileRepo,
    required this.ref,
  });
  Future<UserModel> getUserData() {
    return profileRepo.getProfileData();
  }

  Future<void> updateUsername({
    String? newUsername,
  }) {
    return profileRepo.updateName(
      newUsername: newUsername,
    );
  }

  Future<void> updateDescription({
    String? newDescription,
  }) {
    return profileRepo.updateDescription(
      newDescription: newDescription,
    );
  }

  Future<void> updatePhoneNumber({
    String? newPhonNumber,
  }) {
    return profileRepo.updatePhoneNumber(
      newPhonNumber: newPhonNumber,
    );
  }

  Future<void> updateProfilePic({String? newProfilePic}) async {
    return profileRepo.updateProfilePic(
      newProfilePic: newProfilePic,
    );
  }
}

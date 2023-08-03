import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/repository/auth_repo.dart';
import '../models/user_model.dart';

class AuthController {
  final AuthRepo authRepo;
  final ProviderRef ref; //to pass provider to save user data to fire store
  AuthController(this.authRepo, this.ref);

  Future<void> signInWithPhone(BuildContext context, String phoneNumber) async {
    await authRepo.signInWithPhone(context, phoneNumber);
  }

  Future<void> verifyOtp({
    required BuildContext context,
    required String verificationId,
    required String otpSubmittedFromUser,
  }) async {
    await authRepo.verifyOtp(context, verificationId, otpSubmittedFromUser);
  }

  Future<void> saveUserDataToFireStore(BuildContext context, String name,
      File? profilePic, String description) async {
    authRepo.saveDataToFireStore(
        name: name,
        profilePic: profilePic,
        ref: ref,
        context: context,
        description: description);
  }

  Future<UserModel?> get getUserData async {
    return await authRepo.getUSerData;
  }

  Stream<UserModel> userData(String uid) {
    return authRepo.userData(uid);
  }
}

final authControllerProvider = Provider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository, ref);
});
final userDataProvider = FutureProvider((ref) {
  final authController = ref.watch(authControllerProvider);
  return authController.getUserData;
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Lango/controllers/auth_controller.dart';
import 'package:Lango/repositories/firebase_notification_repo.dart';

class NotificationController {
  final ProviderRef ref;
  final FirebaseMessagingRepo repo;
  NotificationController(this.ref, this.repo);

  Future<void> postMessageNotification(
      {required String body,
      required String title,
      required Map<String, dynamic> data,
      required String token}) async {
    ref.read(userDataProvider).whenData(
          (value) async => repo.postNotification(
              body: body,
              data: data,
              title: '${value!.name} $title',
              token: token),
        );
  }
}

final notificationControllerProvider = Provider((ref) {
  final repo = ref.read(firebaseMessagingRepoProvider);
  return NotificationController(ref, repo);
});

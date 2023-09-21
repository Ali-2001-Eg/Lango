import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/controllers/auth_controller.dart';
import 'package:whatsapp_clone/repositories/firebase_notification_repo.dart';

class NotificationController {
  final ProviderRef ref;
  final FirebaseMessagingRepo repo;
  NotificationController(this.ref, this.repo);

  Future<void> postMessageNotification(
      {required String body,
      required Map<String, dynamic> data,
      required String token}) async {
    ref.read(userDataProvider).whenData(
          (value) async => repo.postNotification(
              body: body,
              data: data,
              title: '${value!.name} Sent You a message',
              token: token),
        );
  }

  Future<void> postCallNotification(
      {required String body,
      required Map<String, dynamic> data,
      required String receiver,
      required String token}) async {
    (value) async => ref
        .read(userDataProvider)
        .whenData((value) => repo.postCallingNotification(
              title: 'Incoming Call',
              body: body,
              token: token,
              data: data,
              channelName: '$receiver ${value!.name}',
            ));
  }
}

final notificationControllerProvider = Provider((ref) {
  final repo = ref.read(firebaseMessagingRepoProvider);
  return NotificationController(ref, repo);
});

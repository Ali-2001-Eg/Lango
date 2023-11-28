import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Lango/repositories/contact_repo.dart';

class SelectContactsController {
  final ProviderRef ref;
  final ContactRepo selectContactsRepo;

  SelectContactsController(this.ref, this.selectContactsRepo);
  Future<void> selectContact(
      Contact selectedContact, BuildContext context) async {
    await selectContactsRepo.selectContact(selectedContact, context);
  }
}

final getContactProvider = FutureProvider((ref) {
  final selectContactRepo = ref.watch(selectContactRepoProvider);
  return selectContactRepo.getContacts;
});
final selectContactsControllerProvider = Provider((ref) {
  final selectContactRepo = ref.watch(selectContactRepoProvider);
  return SelectContactsController(ref, selectContactRepo);
});

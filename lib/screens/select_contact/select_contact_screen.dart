import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:whatsapp_clone/controllers/contact_controller.dart';
import 'package:whatsapp_clone/generated/l10n.dart';
import 'package:whatsapp_clone/screens/auth/login_screen.dart';
import 'package:whatsapp_clone/screens/chat/chat_screen.dart';
import 'package:whatsapp_clone/shared/utils/base/error_screen.dart';
import 'package:whatsapp_clone/shared/widgets/custom_indicator.dart';

class SelectContactsScreen extends ConsumerWidget {
  static const routeName = '/select-contact';
  const SelectContactsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).select_contact),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: ref.watch(getContactProvider).when(
            data: (contact) {
              return _contactList(contact, ref);
            },
            error: (error, stackTrace) =>
                Center(child: ErrorScreen(error: error.toString())),
            loading: () => const CustomIndicator(),
          ),
    );
  }

  ListView _contactList(List<Contact> contactList, WidgetRef ref) =>
      ListView.builder(
        itemCount: contactList.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (_, i) {
          final contact = contactList[i];
          return InkWell(
            onTap: () {
              _selectContact(ref, contact, _);
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(
                  contact.displayName,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
                leading: contact.photo == null
                    ? const CircleAvatar(
                        child: Icon(Icons.person),
                      )
                    : CircleAvatar(
                        backgroundImage: MemoryImage(contact.photo!),
                      ),
              ),
            ),
          );
        },
      );
  void _selectContact(WidgetRef ref, Contact contact, BuildContext context) {
    ref.read(selectContactsControllerProvider).selectContact(contact, context);
  }
}

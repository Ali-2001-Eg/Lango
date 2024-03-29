import 'package:Lango/shared/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Lango/controllers/contact_controller.dart';
import 'package:Lango/generated/l10n.dart';
import 'package:Lango/shared/utils/base/error_screen.dart';
import 'package:Lango/shared/widgets/custom_indicator.dart';

class SelectContactsScreen extends ConsumerWidget {
  static const routeName = '/select-contact';
  const SelectContactsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).select_contact),
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
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                    ? CircleAvatar(
                        backgroundColor:
                            getTheme(_).appBarTheme.backgroundColor,
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
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

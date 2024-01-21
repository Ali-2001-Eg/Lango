// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Lango/controllers/contact_controller.dart';
import 'package:Lango/shared/utils/base/error_screen.dart';
import 'package:Lango/shared/utils/colors.dart';
import 'package:Lango/shared/widgets/custom_indicator.dart';

final selectGroupContacts = StateProvider<List<Contact>>((ref) => []);

class SelectContactsWidget extends ConsumerStatefulWidget {
  const SelectContactsWidget({super.key});

  @override
  ConsumerState createState() => _SelectContactsWidgetState();
}

List<int> selectedContactsIndex = [];

class _SelectContactsWidgetState extends ConsumerState<SelectContactsWidget> {
  @override
  Widget build(BuildContext context) {
    // debugPrint(selectedContactsIndex);
    return ref.watch(getContactProvider).when(
          data: (data) => Expanded(
              child: ListView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: data.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final contact = data[index];
              // debugPrint(data.length);
              return InkWell(
                onTap: () => _selectContact(index, contact),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      contact.displayName,
                      style: const TextStyle(fontSize: 18),
                    ),
                    trailing: selectedContactsIndex.contains(index)
                        ? IconButton(
                            onPressed: () {
                              _selectContact(index, contact);
                            },
                            icon: const Icon(
                              Icons.check_box,
                              color: tabColor,
                            ))
                        : const Icon(Icons.crop_square),
                  ),
                ),
              );
            },
          )),
          error: (error, stackTrace) => ErrorScreen(error: error.toString()),
          loading: () => const CustomIndicator(),
        );
  }

  void _selectContact(int index, Contact contact) {
    if (selectedContactsIndex.contains(index)) {
      selectedContactsIndex.remove(index);
    } else {
      selectedContactsIndex.add(index);
    }
    setState(() {});
    ref.read(selectGroupContacts.state).update((state) => [...state, contact]);
  }
}

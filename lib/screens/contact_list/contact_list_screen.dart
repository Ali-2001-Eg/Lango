import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_clone/models/chat_contacts_model.dart';
import 'package:whatsapp_clone/screens/chat/chat_screen.dart';
import 'package:whatsapp_clone/shared/utils/base/error_screen.dart';
import 'package:whatsapp_clone/shared/widgets/custom_indicator.dart';
import 'package:whatsapp_clone/shared/widgets/time_text_formatter.dart';
import '../../controllers/chat_controller.dart';

class ContactListScreen extends ConsumerWidget {
  const ContactListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              StreamBuilder<List<ChatContactModel>>(
                  stream: ref.watch(chatControllerProvider).contacts,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CustomIndicator();
                    }
                    if (snapshot.hasError) {
                      return ErrorScreen(error: snapshot.error.toString());
                    } else {
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final contacts = snapshot.data![index];
                          // print(contacts.isOnlyText);
                          // print(contacts.type);
                          return Column(
                            children: [
                              InkWell(
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  ChatScreen.routeName,
                                  arguments: {
                                    'name': contacts.name,
                                    'uid': contacts.contactId,
                                    'profilePic': contacts.profilePic,
                                    'groupId': ref
                                        .watch(chatControllerProvider)
                                        .user
                                        ?.groupId,
                                    'description': ref
                                        .watch(chatControllerProvider)
                                        .user
                                        ?.description,
                                    'isOnline': ref
                                        .watch(chatControllerProvider)
                                        .user
                                        ?.isOnline,
                                    'phoneNumber': ref
                                        .watch(chatControllerProvider)
                                        .user
                                        ?.phoneNumber,
                                  },
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: ListTile(
                                      title: Text(
                                        contacts.name,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          contacts.lastMessage
                                                  .startsWith('https')
                                              ? contacts.type
                                              : contacts.lastMessage,
                                          style: const TextStyle(fontSize: 15),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      leading: CircleAvatar(
                                        backgroundImage:
                                            CachedNetworkImageProvider(contacts.profilePic),
                                        radius: 30,
                                      ),
                                      trailing: TimeTextFormatter(
                                        time: contacts.timeSent,
                                      )),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  })
            ],
          ),
        ));
  }
}

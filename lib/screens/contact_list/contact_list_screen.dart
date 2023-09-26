import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:whatsapp_clone/generated/l10n.dart';
import 'package:whatsapp_clone/models/chat_contacts_model.dart';
import 'package:whatsapp_clone/models/group_model.dart';
import 'package:whatsapp_clone/screens/chat/chat_screen.dart';
import 'package:whatsapp_clone/shared/enums/message_enum.dart';
import 'package:whatsapp_clone/shared/notifiers/theme_notifier.dart';
import 'package:whatsapp_clone/shared/utils/base/error_screen.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';
import 'package:whatsapp_clone/shared/widgets/custom_indicator.dart';
import 'package:whatsapp_clone/shared/widgets/time_text_formatter.dart';
import '../../controllers/chat_controller.dart';
import '../../repositories/firebase_notification_repo.dart';
import '../../shared/enums/app_theme.dart';
import '../../shared/utils/colors.dart';
import '../select_contact/select_contact_screen.dart';

class ContactListScreen extends ConsumerWidget {
  const ContactListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(appThemeProvider);

    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    S.of(context).contacts,
                    style: getTextTheme(context),
                  ),
                ),
                //single chat
                Container(
                  constraints: BoxConstraints(
                    minHeight: size(context).height / 3,
                  ),
                  child: StreamBuilder<List<ChatContactModel>>(
                      stream: ref.watch(chatControllerProvider).contacts,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CustomIndicator();
                        }
                        if (snapshot.data!.isEmpty) {
                          return Center(
                              child: Column(
                            children: [
                              const Text('Chat with your first contact'),
                              SizedBox(
                                  width: 200,
                                  child: Lottie.asset(
                                      'assets/json/empty_chat.json')),
                            ],
                          ));
                        }
                        if (snapshot.hasError) {
                          return ErrorScreen(error: snapshot.error.toString());
                        } else {
                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final contacts = snapshot.data![index];
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
                                        'isGroupChat': false,
                                        'token': contacts.token,
                                      },
                                    ),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: ListTile(
                                          title: Text(
                                            contacts.name,
                                            style: getTextTheme(context),
                                          ),
                                          subtitle: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 6),
                                            child: Text(
                                              contacts.type == 'text'
                                                  ? contacts.lastMessage
                                                  : contacts.type,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .copyWith(
                                                    fontSize: 15,
                                                    color:
                                                        appTheme.selectedTheme ==
                                                                'light'
                                                            ? Colors.black
                                                            : Colors.grey,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          leading: CircleAvatar(
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                                    contacts.profilePic),
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
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    S.of(context).groups,
                    style: getTextTheme(context),
                  ),
                ),
                const Divider(color: greyColor),
                //group stream
                StreamBuilder<List<GroupModel>>(
                    stream: ref.watch(chatControllerProvider).groups,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CustomIndicator();
                      }
                      if (snapshot.data!.isEmpty) {
                        return Center(
                            child: Column(
                          children: [
                            const Text('Search & Join Groups ...'),
                            SizedBox(
                                width: 200,
                                child: Lottie.asset(
                                    'assets/json/empty_chat.json')),
                          ],
                        ));
                      }
                      if (snapshot.hasError) {
                        return ErrorScreen(error: snapshot.error.toString());
                      } else {
                        return ListView.builder(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final group = snapshot.data![index];
                            // print(contacts.isOnlyText);

                            return Column(
                              children: [
                                InkWell(
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    ChatScreen.routeName,
                                    arguments: {
                                      'name': group.name,
                                      'uid': group.groupId,
                                      'profilePic': group.groupPic,
                                      'groupId': null,
                                      'description': '',
                                      'isOnline': false,
                                      'phoneNumber': '',
                                      'isGroupChat': true,
                                      'token': ref
                                          .watch(chatControllerProvider)
                                          .user
                                          ?.token,
                                    },
                                  ),
                                  child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: ListTile(
                                        title: Text(
                                          group.name,
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                        subtitle: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 6),
                                          child: Text(
                                            group.lastMessageType.type == 'text'
                                                ? group.lastMessage
                                                : group.lastMessageType.type,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(
                                                  fontSize: 15,
                                                  color:
                                                      appTheme.selectedTheme ==
                                                              'light'
                                                          ? Colors.black
                                                          : Colors.grey,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        leading: CircleAvatar(
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                                  group.groupPic),
                                          radius: 30,
                                        ),
                                        trailing: TimeTextFormatter(
                                            time: group.timeSent),
                                      )),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    })
              ],
            ),
          )),
      floatingActionButton: FloatingActionButton(
        heroTag: 'btn4',
        onPressed: () async {
          Navigator.pushNamed(context, SelectContactsScreen.routeName);
        },
        child: const Icon(
          Icons.chat,
          color: Colors.white,
        ),
      ),
    );
  }
}

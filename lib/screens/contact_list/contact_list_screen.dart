import 'package:Lango/shared/widgets/custom_stream_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:Lango/generated/l10n.dart';
import 'package:Lango/models/chat_contacts_model.dart';
import 'package:Lango/models/group_model.dart';
import 'package:Lango/screens/chat/chat_screen.dart';
import 'package:Lango/shared/notifiers/theme_notifier.dart';
// import 'package:Lango/shared/utils/base/error_screen.dart';
import 'package:Lango/shared/utils/functions.dart';
import 'package:Lango/shared/widgets/custom_indicator.dart';
import 'package:Lango/shared/widgets/time_text_formatter.dart';
import '../../controllers/chat_controller.dart';
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
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                S.of(context).contacts,
                style: getTextTheme(context, ref),
              ),
            ),
            //single chat
            Container(
                constraints: BoxConstraints(
                  minHeight: size(context).height / 3,
                ),
                child: CustomStreamOrFutureWidget<List<ChatContactModel>>(
                  stream: contactProvider,
                  builder: (data) {
                    if (data.isEmpty) {
                      return Center(
                          child: Column(
                        children: [
                          SizedBox(
                              width: 200,
                              child:
                                  Lottie.asset('assets/json/empty_chat.json')),
                        ],
                      ));
                    } else {
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final contacts = data[index];
                          // debugPrint(contacts.type);
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
                                    'phoneNumber': contacts.phoneNumber,
                                    'isGroupChat': false,
                                    'token': contacts.token,
                                  },
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: ListTile(
                                      title: Text(
                                        contacts.name,
                                        style: getTextTheme(context, ref),
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          contacts.type == 'text'
                                              ? contacts.lastMessage
                                              : contacts.type,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                fontSize: 15,
                                                color: appTheme.selectedTheme ==
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
                  },
                )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                S.of(context).groups,
                style: getTextTheme(context, ref),
              ),
            ),
            const Divider(color: greyColor),
            //group stream
            CustomStreamOrFutureWidget<List<GroupModel>>(
              stream: groupProvider,
              builder: (data) {
                if (data.isEmpty) {
                  return Center(
                      child: Column(
                    children: [
                      SizedBox(
                          width: 200,
                          child: Lottie.asset('assets/json/empty_chat.json')),
                    ],
                  ));
                } else {
                  return ListView.builder(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final group = data[index];
                      // debugPrint(contacts.isOnlyText);

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
                                'token': '',
                              },
                            ),
                            child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  title: Text(
                                    group.name,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      group.lastMessageType.type == 'text'
                                          ? group.lastMessage
                                          : group.lastMessageType.type,
                                    
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  leading: CircleAvatar(
                                    backgroundImage: CachedNetworkImageProvider(
                                        group.groupPic),
                                    radius: 30,
                                  ),
                                  trailing:
                                      TimeTextFormatter(time: group.timeSent),
                                )),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            )
          ]),
        ),
      ),
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

final groupProvider = StreamProvider((ref) {
  return ref.read(chatControllerProvider).groups;
});
final contactProvider = StreamProvider((ref) {
  return ref.read(chatControllerProvider).contacts;
});

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:whatsapp_clone/controllers/group_controller.dart';
import 'package:whatsapp_clone/screens/chat/chat_screen.dart';
import 'package:whatsapp_clone/shared/utils/base/error_screen.dart';
import 'package:whatsapp_clone/shared/widgets/custom_button.dart';
import 'package:whatsapp_clone/shared/widgets/custom_indicator.dart';

import '../../models/user_model.dart';
import '../../shared/notifiers/theme_notifier.dart';
import '../../shared/utils/colors.dart';
import '../../shared/utils/functions.dart';

class DescriptionScreen extends ConsumerWidget {
  final bool isGroupChat;
  final String name;
  final String phoneNumber;
  final String pic;
  final String description;
  final String id;
  DescriptionScreen({
    super.key,
    required this.isGroupChat,
    required this.name,
    required this.phoneNumber,
    required this.pic,
    required this.description,
    required this.id,
  });

  bool _isJoined = false;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(appThemeProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          name,
          style: getTextTheme(context)!.copyWith(
              color: appTheme.selectedTheme == 'light'
                  ? lightScaffold
                  : Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: _descreptionbody(context, ref),
      ),
    );
  }

  Widget _descreptionbody(BuildContext context, WidgetRef ref) {
    _isUserJoined(id, ref);
    return SizedBox(
      child: Column(
        children: [
          Center(
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(pic),
              radius: 70,
            ),
          ),
          _buildDescriptionTile(
              context, isGroupChat ? 'Group Name' : 'Username', name),
          !isGroupChat
              ? _buildDescriptionTile(context, 'Description', description)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Group Members',
                        style: getTextTheme(context),
                      ),
                    ),
                    const Divider(
                      //indent: 50,
                      endIndent: 50,
                      thickness: 5,
                    ),
                    _groupMembers(ref),
                  ],
                ),
          !isGroupChat
              ? GestureDetector(
                  onTap: () =>
                      Clipboard.setData(ClipboardData(text: phoneNumber)).then(
                          (value) =>
                              customSnackBar('Copied Succesfully', context)),
                  child: _buildDescriptionTile(
                      context, 'PhoneNumber', phoneNumber,
                      isPhoneNumber: true),
                )
              : StatefulBuilder(builder: (context, setState) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 15),
                    child: CustomButton(
                      onPress: () {
                        ref.read(groupControllerProvider).toggleGroupJoin(id);
                        setState(() => _isJoined = !_isJoined);
                      },
                      text: !_isJoined ? 'Leave Group' : 'Join Group',
                    ),
                  );
                }),
        ],
      ),
    );
  }

  FutureBuilder<List<UserModel>> _groupMembers(WidgetRef ref) {
    return FutureBuilder<List<UserModel>>(
        future: ref.read(groupControllerProvider).getGroupMembers(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomIndicator();
          } else if (snapshot.hasError) {
            return ErrorScreen(
              error: snapshot.error.toString(),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            const Text('there is no members in this group');
          }

          return ListView.builder(
              itemCount: snapshot.data!.length,
              shrinkWrap: true,
              itemBuilder: (_, i) {
                var member = snapshot.data![i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: ListTile(
                    title: Text(member.name),
                    subtitle: Text(member.isOnline ? 'online' : 'offline'),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage:
                          CachedNetworkImageProvider(member.profilePic),
                    ),
                    trailing:
                        member.uid != FirebaseAuth.instance.currentUser!.uid
                            ? IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatScreen(
                                          name: member.name,
                                          uid: member.uid,
                                          description: member.description,
                                          phoneNumber: member.phoneNumber,
                                          isGroupChat: false,
                                          profilePic: member.profilePic,
                                          token: member.token,
                                          isOnline: member.isOnline),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.message,
                                  color: getTheme(context).cardColor,
                                ))
                            : null,
                  ),
                );
              });
        });
  }

  _buildDescriptionTile(BuildContext context, String label, String description,
      {bool isPhoneNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            label,
            style: getTextTheme(context),
          ),
        ),
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(description, style: getTextTheme(context)),
              const SizedBox(
                width: 15,
              ),
              isPhoneNumber
                  ? Icon(
                      Icons.copy,
                      color: getTheme(context).cardColor,
                    )
                  : Container()
            ],
          ),
        )
      ],
    );
  }

  Future<bool> _isUserJoined(String groupId, ref) async {
    return await ref
        .read(groupControllerProvider)
        .isUserJoined(groupId)
        .then((value) {
      print('value is $value');
      return value;
    });
  }
}

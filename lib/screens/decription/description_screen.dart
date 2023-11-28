// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:Lango/controllers/group_controller.dart';
import 'package:Lango/generated/l10n.dart';
import 'package:Lango/screens/call/call_pickup_screen.dart';
import 'package:Lango/screens/chat/chat_screen.dart';
import 'package:Lango/screens/home_screen.dart';
import 'package:Lango/shared/utils/base/error_screen.dart';
import 'package:Lango/shared/widgets/custom_button.dart';
import 'package:Lango/shared/widgets/custom_indicator.dart';

import '../../models/user_model.dart';
import '../../repositories/auth_repo.dart';
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
  List<UserModel> modifiedList = [];
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(appThemeProvider.notifier);
    return CallPickupScreen(
      scaffold: Scaffold(
        appBar: AppBar(
          title: Text(
            name,
            style: getTextTheme(context, ref).copyWith(
                color: appTheme.selectedTheme == 'light'
                    ? lightScaffold
                    : Colors.white),
          ),
          actions: [
            isGroupChat
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: IconButton(
                        onPressed: () {
                          _leaveGroup(ref, context);
                        },
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.red,
                        )),
                  )
                : Container(),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: _descreptionbody(context, ref, appTheme),
        ),
      ),
    );
  }

  Widget _descreptionbody(
      BuildContext context, WidgetRef ref, ThemeNotifier appTheme) {
    //_isUserJoined(id, ref);
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
              context,
              isGroupChat ? S.of(context).group_name : S.of(context).username,
              name,
              ref),
          !isGroupChat
              ? _buildDescriptionTile(
                  context, S.of(context).description, description, ref)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        S.of(context).group_members,
                        style: getTextTheme(context, ref),
                      ),
                    ),
                    const Divider(
                      //color: greyColor,
                      endIndent: 50,
                      thickness: 5,
                    ),
                    _groupMembers(ref, appTheme),
                  ],
                ),
          !isGroupChat
              ? GestureDetector(
                  onTap: () =>
                      Clipboard.setData(ClipboardData(text: phoneNumber)).then(
                          (value) => customSnackBar(
                              S.of(context).copy_snackbar, context,
                              color: Colors.green)),
                  child: _buildDescriptionTile(
                    context,
                    S.of(context).phone_nember,
                    phoneNumber,
                    ref,
                    isPhoneNumber: true,
                  ),
                )
              : StreamBuilder(
                  stream: _isUserJoined(id, ref),
                  builder: (context, snap) {
                    if (snap.hasData) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 15),
                        child: CustomButton(
                            onPress: () {
                              snap.data
                                  ? _leaveGroup(ref, context)
                                  : _joinGroup(ref, context);
                            },
                            text: snap.data
                                ? S.of(context).leave_group
                                : S.of(context).join_group),
                      );
                    } else {
                      return const CustomIndicator();
                    }
                  }),
        ],
      ),
    );
  }

  void _leaveGroup(WidgetRef ref, BuildContext context) {
    ref.read(groupControllerProvider).leaveGroup(id).then((value) {
      customSnackBar(
          !isArabic ? 'You left $name successfully!' : ' تم مغادره بنجاح $name',
          context,
          color: Colors.green);
      return Navigator.pushNamedAndRemoveUntil(
          context, HomeScreen.routeName, (route) => false);
    });
  }

  void _joinGroup(WidgetRef ref, BuildContext context) {
    ref
        .read(groupControllerProvider)
        .joinGroup(id)
        .then((value) => Navigator.pop(context));
  }

  FutureBuilder<List<UserModel>> _groupMembers(
      WidgetRef ref, ThemeNotifier appTheme) {
    return FutureBuilder<List<UserModel>>(
        future: ref.read(groupControllerProvider).getGroupMembers(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomIndicator();
          } else if (snapshot.hasError) {
            return ErrorScreen(
              error: snapshot.error.toString(),
            );
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return Center(child: Text(S.of(context).empty_group));
          }

          return ListView.builder(
              itemCount: snapshot.data!.length,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, i) {
                var member = _setMeFirstMember(snapshot, ref)[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: ListTile(
                    title: Text(member.name),
                    subtitle: Text(
                      member.isOnline
                          ? S.of(context).online
                          : S.of(context).offline,
                      style: TextStyle(
                        color: appTheme.selectedTheme == 'light'
                            ? getTheme(context).appBarTheme.backgroundColor
                            : getTheme(context).cardColor,
                      ),
                    ),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage:
                          CachedNetworkImageProvider(member.profilePic),
                    ),
                    trailing: member.uid !=
                            ref
                                .read(authRepositoryProvider)
                                .auth
                                .currentUser!
                                .uid
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
                              color: appTheme.selectedTheme == 'light'
                                  ? getTheme(context)
                                      .appBarTheme
                                      .backgroundColor
                                  : getTheme(context).cardColor,
                            ))
                        : null,
                  ),
                );
              });
        });
  }

  _buildDescriptionTile(
      BuildContext context, String label, String description, ref,
      {bool isPhoneNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            label,
            style: getTextTheme(context, ref),
          ),
        ),
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
                color: getTheme(context).appBarTheme.backgroundColor!),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(description, style: getTextTheme(context, ref)),
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
          ),
        )
      ],
    );
  }

  Stream _isUserJoined(String groupId, ref) {
    return ref.read(groupControllerProvider).isUserJoined(groupId);
  }

  List<UserModel> _setMeFirstMember(
      AsyncSnapshot<List<UserModel>> snapshot, WidgetRef ref) {
    int myIndex = snapshot.data!.indexWhere((element) =>
        element.uid == ref.read(authRepositoryProvider).auth.currentUser!.uid);
    if (myIndex != -1) {
      UserModel myObject = snapshot.data!.removeAt(myIndex);
      modifiedList.add(myObject);
    }
    modifiedList.addAll(snapshot.data!);
    return modifiedList;
  }
}

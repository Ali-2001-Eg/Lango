import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/screens/call/call_pickup_screen.dart';
import 'package:whatsapp_clone/screens/chat/chat_screen.dart';
import 'package:whatsapp_clone/shared/utils/base/error_screen.dart';
import 'package:whatsapp_clone/shared/utils/colors.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';
import 'package:whatsapp_clone/shared/widgets/custom_indicator.dart';

import '../../controllers/chat_controller.dart';
import '../../controllers/group_controller.dart';
import '../../generated/l10n.dart';
import '../../models/group_model.dart';

class SearchScreen extends ConsumerStatefulWidget {
  static const String routeName = "/search-screen";
  const SearchScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePage();
}

class _HomePage extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<GroupModel> filteredList = [];
  List<GroupModel> allGroups = [];
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    filteredList = allGroups;
  }

  @override
  Widget build(BuildContext context) {
    //_focusNode.requestFocus();
    return CallPickupScreen(
      scaffold: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            textAlign: TextAlign.center,
            onChanged: (value) => _filterGroups(_searchController.text.trim()),
            decoration: InputDecoration.collapsed(
              filled: false,
              hintStyle: getTextTheme(context, ref).copyWith(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w300),
              hintText: 'Search for a group',
            ),
          ),
        ),
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(),
          child: StreamBuilder<List<GroupModel>>(
            stream: ref.read(groupControllerProvider).groups,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'No Groups with this name',
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return ListView.builder(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: _searchController.text.isEmpty
                      ? snapshot.data!.length
                      : filteredList.length,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (_, i) {
                    if (_searchController.text.isEmpty) {
                      allGroups = snapshot.data!;
                      print('filtered groups $filteredList\n');
                      GroupModel group = snapshot.data![i];
                      return _groupTile(group, context);
                    } else {
                      //for searched groups
                      return _groupTile(filteredList[i], context);
                    }
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Stream<bool> _isUserJoined(String groupId) {
    return ref.read(groupControllerProvider).isUserJoined(groupId);
  }

  void _filterGroups(String query) {
    List<GroupModel> tempList = [];
    tempList.addAll(allGroups);

    tempList.retainWhere(
        (element) => element.name.toLowerCase().contains(query.toLowerCase()));

    setState(() {
      filteredList = tempList;
    });
  }

  Padding _groupTile(GroupModel group, BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(15),
        child: ListTile(
          title: Text(
            group.name,
            style: const TextStyle(fontSize: 20),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${group.membersUid.length} subscribers',
                style: getTextTheme(context, ref).copyWith(
                    fontSize: 13, color: getTheme(context).hoverColor),
              ),
              const Divider(
                thickness: 2,
              )
            ],
          ),
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: CachedNetworkImageProvider(group.groupPic),
          ),
          onTap: () {
            Navigator.pushNamed(
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
                'token': ref.watch(chatControllerProvider).user?.token,
              },
            );
          },
        ));
  }
}

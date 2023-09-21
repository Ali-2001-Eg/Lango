import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/screens/chat/chat_screen.dart';
import 'package:whatsapp_clone/shared/utils/base/error_screen.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';

import '../../controllers/chat_controller.dart';
import '../../controllers/group_controller.dart';
import '../../models/group_model.dart';

class SearchScreen extends ConsumerStatefulWidget {
  static const String routeName = "/search-screen";
  const SearchScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePage();
}

class _HomePage extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  bool _isJoined = false;
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          decoration: const InputDecoration(
              filled: false,
              hintText: 'Search',
              hintStyle: TextStyle(fontSize: 20, color: Colors.white)),
          onChanged: (value) {
            print(value);
            ref.read(groupControllerProvider).searchByName(value.trim());
          },
        ),
      ),
      body: StreamBuilder<List<GroupModel>>(
        stream: ref
            .read(groupControllerProvider)
            .searchByName(_searchController.text.trim()),
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
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (_, i) {
              GroupModel group = snapshot.data![i];
              return _groupTile(group, _);
            },
          );
        },
      ),
    );
  }

  Future<bool> _isUserJoined(String groupId) async {
    return await ref
        .read(groupControllerProvider)
        .isUserJoined(groupId)
        .then((value) {
      _isJoined = value;
      return value;
    });
  }

  Padding _groupTile(GroupModel group, BuildContext context) {
    _isUserJoined(group.groupId);
    return Padding(
      padding: const EdgeInsets.all(15),
      child: ListTile(
        title: Text(
          group.name,
          style: const TextStyle(fontSize: 20),
        ),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: CachedNetworkImageProvider(group.groupPic),
        ),
        trailing: ElevatedButton(
          onPressed: () {
            ref.read(groupControllerProvider).toggleGroupJoin(group.groupId);
          },
          style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll<Color>(
                getTheme(context).cardColor,
              ),
              padding: const MaterialStatePropertyAll<EdgeInsets>(
                  EdgeInsets.all(10))),
          child: Text(
            _isJoined ? 'Leave Group' : 'Join Group',
          ),
        ),
        onTap: () async {
          !_isJoined
              ? Navigator.pushNamed(context, ChatScreen.routeName, arguments: {
                  'name': group.name,
                  'uid': group.groupId,
                  'profilePic': group.groupPic,
                  'groupId': <String>[],
                  'description': '',
                  'isOnline': false,
                  'phoneNumber': '',
                  'isGroupChat': true,
                  'token': ref.watch(chatControllerProvider).user?.token,
                })
              : null;
        },
      ),
    );
  }
}

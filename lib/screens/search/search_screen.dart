import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:Lango/screens/call/call_pickup_screen.dart';
import 'package:Lango/screens/chat/chat_screen.dart';
import 'package:Lango/shared/utils/functions.dart';

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
    _focusNode.requestFocus();
    //filteredList = allGroups;
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
            style: const TextStyle(decorationThickness: 0, color: Colors.white),
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            //textAlign: TextAlign.center,
            onChanged: (value) => _filterGroups(_searchController.text.trim()),
            decoration: InputDecoration(
              filled: false,
              isCollapsed: true,
              suffixIcon: const Icon(
                Icons.search,
                color: Colors.white,
              ),
              hintStyle: getTextTheme(context, ref).copyWith(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w300),
              hintText: S.of(context).search_hint,
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
              }
              if (snapshot.hasData && filteredList.isNotEmpty) {
                //debugPrint(allGroups.length);
                return ListView.builder(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: _searchController.text.trim().isEmpty
                      ? snapshot.data!.length
                      : filteredList.length,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (_, i) {
                    if (_searchController.text.isEmpty) {
                      allGroups = snapshot.data!;
                      //debugPrint('filtered groups $filteredList\n');
                      GroupModel group = snapshot.data![i];
                      return _groupTile(group, context);
                    } else {
                      if (kDebugMode) {
                        debugPrint(
                            'filtered list is ${filteredList.map((e) => e.name)}');
                      }
                      //for searched groups
                      return _groupTile(filteredList[i], context);
                    }
                  },
                );
              }
              return SizedBox(
                height: size(context).height,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 300,
                        child: Lottie.asset('assets/json/empty_search.json'),
                      ),
                      Text(
                        'No groups with this name',
                        style: getTextTheme(context, ref),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _filterGroups(String query) {
    setState(() {
      filteredList = [];
    });
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
                !isArabic
                    ? '${group.membersUid.length} subscribers'
                    : '${group.membersUid.length} مشتركين',
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
                'token': '',
              },
            );
          },
        ));
  }
}

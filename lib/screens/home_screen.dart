import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/controllers/auth_controller.dart';
import 'package:whatsapp_clone/screens/contact_list/contact_list_screen.dart';
import 'package:whatsapp_clone/screens/select_contact/select_contact_screen.dart';
import 'package:whatsapp_clone/screens/status/confirm_status_screen.dart';
import 'package:whatsapp_clone/screens/status/status_contacts_screen.dart';
import 'package:whatsapp_clone/shared/enums/message_enum.dart';
import 'package:whatsapp_clone/shared/utils/colors.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static const routeName = '/home-screen';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController tabBarController;
  @override
  void initState() {
    // TODO: implement initState
    tabBarController = TabController(length: 3, vsync: this);
    //to listen to changes in user state
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  //to know if user left app or not
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    switch (state) {
      case AppLifecycleState.resumed:
        ref.read(authControllerProvider).setUserState(true);
        break;
      case AppLifecycleState.inactive:
        ref.read(authControllerProvider).setUserState(false);
        break;
      case AppLifecycleState.paused:
        ref.read(authControllerProvider).setUserState(false);
        break;
      case AppLifecycleState.detached:
        ref.read(authControllerProvider).setUserState(false);
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: appBarColor,
          centerTitle: false,
          title: const Text(
            'WhatsApp',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.grey),
              onPressed: () {},
            ),
            PopupMenuButton(
              icon: const Icon(
                Icons.more_vert,
                color: Colors.grey,
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                    child: const Text(
                      'Create Group',
                    ),
                    onTap: () {}),
                PopupMenuItem(
                    child: const Text(
                      'Linked Devices',
                    ),
                    onTap: () {}),
                PopupMenuItem(
                    child: const Text(
                      'Starred Messages',
                    ),
                    onTap: () {}),
                PopupMenuItem(
                    child: const Text(
                      'Settings',
                    ),
                    onTap: () {}),
              ],
            ),
          ],
          bottom: TabBar(
            controller: tabBarController,
            indicatorColor: tabColor,
            indicatorWeight: 4,
            labelColor: tabColor,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            tabs: const [
              Tab(
                text: 'CHATS',
              ),
              Tab(
                text: 'STATUS',
              ),
              Tab(
                text: 'CALLS',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabBarController,
          children: const [
            ContactListScreen(),
            StatusContactsScreen(),
            Center(child: Text('Calls')),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (tabBarController.index == 0) {
              Navigator.pushNamed(context, SelectContactsScreen.routeName);
            } else {
              File? pickedImage = await pickImageFromGallery(context);
              if (pickedImage != null) {
               Navigator.push(context, MaterialPageRoute(builder: (context) => ConfirmStatusScreen(file: pickedImage, type: MessageEnum.image),));
              }
            }
          },
          elevation: 0,
          backgroundColor: tabColor,
          child: Icon(
            Icons.chat,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

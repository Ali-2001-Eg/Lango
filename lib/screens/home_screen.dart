import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/controllers/auth_controller.dart';
import 'package:whatsapp_clone/screens/contact_list/contact_list_screen.dart';
import 'package:whatsapp_clone/screens/group/create_group_screen.dart';
import 'package:whatsapp_clone/screens/settings/settings_screen.dart';
import 'package:whatsapp_clone/screens/status/status_contacts_screen.dart';
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
  final GlobalKey<ScaffoldState> myWidgetKey = GlobalKey<ScaffoldState>();

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
    tabBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: myWidgetKey,
        appBar: AppBar(
          elevation: 0,
          // backgroundColor: appBarColor,
          centerTitle: false,
          title: const Text(
            'WhatsApp',
            style: TextStyle(
              fontSize: 20,
              // color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, ),
              onPressed: () {},
            ),
            PopupMenuButton(
              icon: const Icon(
                Icons.more_vert,
                // color: Colors.grey,
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                    child: const Text(
                      'Create Group',
                    ),
                    onTap: () => Future(() => Navigator.of(context)
                        .pushNamed(CreateGroupScreen.routeName))),
                PopupMenuItem(
                    child: const Text(
                      'Linked Devices',
                    ),
                    onTap: () {}),
                PopupMenuItem(
                    child: const Text(
                      'Settings',
                    ),
                    onTap: () {
                      Future(
                          () => navToNamed(context, SettingsScreen.routeName));
                    }),
              ],
            ),
          ],
          bottom: TabBar(
            onTap: (value) => setState(() {
              value = tabBarController.index;
            }),
            controller: tabBarController,
            indicatorColor: Theme.of(context).indicatorColor,
            indicatorWeight: 4,
            labelColor: Theme.of(context).indicatorColor,
            unselectedLabelColor: Colors.white,
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
          physics: const BouncingScrollPhysics(),
          controller: tabBarController,
          children: [
            const ContactListScreen(),
            StatusContactsScreen(),
            const Center(child: Text('Calls')),
          ],
        ),
      ),
    );
  }
}

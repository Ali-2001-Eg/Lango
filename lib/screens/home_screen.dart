import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/controllers/auth_controller.dart';
import 'package:whatsapp_clone/screens/contact_list/contact_list_screen.dart';
import 'package:whatsapp_clone/screens/group/create_group_screen.dart';
import 'package:whatsapp_clone/screens/settings/settings_screen.dart';
import 'package:whatsapp_clone/screens/status/status_contacts_screen.dart';
import 'package:whatsapp_clone/shared/utils/colors.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';
import 'package:whatsapp_clone/generated/l10n.dart';

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
            'Chat & Live',
            style: TextStyle(
              fontSize: 20,
              // color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.search,
              ),
              onPressed: () {},
            ),
            PopupMenuButton(
              icon: const Icon(
                Icons.more_vert,
                // color: Colors.grey,
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                    child: Text(
                      S.of(context).create_group,
                      style: getTextTheme(context)!.copyWith(fontSize: 18),
                    ),
                    onTap: () => Future(() => Navigator.of(context)
                        .pushNamed(CreateGroupScreen.routeName))),
                PopupMenuItem(
                    child: Text(
                      S.of(context).settings,
                      style: getTextTheme(context)!.copyWith(fontSize: 18),
                    ),
                    onTap: () {
                      Future(
                          () => navToNamed(context, SettingsScreen.routeName));
                    }),
                PopupMenuItem(
                    child: Text(
                      'About us',
                      style: getTextTheme(context)!.copyWith(fontSize: 18),
                    ),
                    onTap: () {}),
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
            tabs: [
              Tab(
                text: S.of(context).chat,
              ),
              Tab(
                text: S.of(context).status,
              ),
              Tab(
                text: S.of(context).calls,
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

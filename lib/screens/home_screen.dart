import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Lango/controllers/auth_controller.dart';
import 'package:Lango/screens/call/call_pickup_screen.dart';
import 'package:Lango/screens/contact_list/contact_list_screen.dart';
import 'package:Lango/screens/group/create_group_screen.dart';
import 'package:Lango/screens/profile/edit_profile_screen.dart';
import 'package:Lango/screens/search/search_screen.dart';
import 'package:Lango/screens/settings/settings_screen.dart';
import 'package:Lango/screens/status/status_contacts_screen.dart';
import 'package:Lango/shared/utils/functions.dart';
import 'package:Lango/generated/l10n.dart';

import 'call_history/call_history_screen.dart';

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
    tabBarController = TabController(length: 3, vsync: this);
    //to listen to changes in user state
    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  //to know if user left app or not
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
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
    //final themeNotifier = ref.read(appThemeProvider);

    return DefaultTabController(
      length: 3,
      child: CallPickupScreen(
        scaffold: Scaffold(
          key: myWidgetKey,
          appBar: AppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
            // backgroundColor: appBarColor,
            centerTitle: false,
            title: const Text(
              'LANGO',
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
                onPressed: () {
                  Navigator.pushNamed(context, SearchScreen.routeName);
                },
              ),
              PopupMenuButton(
                //color: Colors.white,
                icon: const Icon(
                  Icons.more_vert,
                  // color: Colors.grey,
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                      child: Text(
                        S.of(context).create_group,
                        style: getTextTheme(context, ref)
                            .copyWith(fontSize: 18, color: Colors.white),
                      ),
                      onTap: () => Future(() => Navigator.of(context)
                          .pushNamed(CreateGroupScreen.routeName))),
                  PopupMenuItem(
                      child: Text(
                        S.of(context).settings,
                        style: getTextTheme(context, ref)
                            .copyWith(fontSize: 18, color: Colors.white),
                      ),
                      onTap: () {
                        Future(() =>
                            navToNamed(context, SettingsScreen.routeName));
                      }),
                  PopupMenuItem(
                      child: Text(
                        S.of(context).edit_profile,
                        style: getTextTheme(context, ref)
                            .copyWith(fontSize: 18, color: Colors.white),
                      ),
                      onTap: () {
                        Future(() =>
                            navToNamed(context, EditProfileScreen.routeName));
                      }),
                ],
              ),
            ],
            bottom: TabBar(
              onTap: (value) => setState(() {
                value = tabBarController.index;
              }),
              controller: tabBarController,
              indicatorColor: getTheme(context).indicatorColor,
              indicatorWeight: 4,
              labelColor: getTheme(context).indicatorColor,
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
              const CallHistoryScreen(),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quit_addiction_app/models/addiction_item_screen_args.dart';
import 'package:flutter_quit_addiction_app/screens/create_addiction_screen.dart';
import 'package:flutter_quit_addiction_app/widgets/addiction_item.dart';
import 'package:flutter_quit_addiction_app/widgets/settings_view.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class AddictionItemScreen extends StatefulWidget {
  static const routeName = '/addiction-item';

  @override
  _AddictionItemState createState() => _AddictionItemState();
}

class _AddictionItemState extends State<AddictionItemScreen> {
  @override
  Widget build(BuildContext context) {
    final AddictionItemScreenArgs args =
        ModalRoute.of(context).settings.arguments;

    List<Widget> _buildScreens() {
      return [
        AddictionItem(args: args),
        SettingsView(),
      ];
    }

    List<PersistentBottomNavBarItem> _navBarsItems() {
      return [
        PersistentBottomNavBarItem(
          icon: Icon(CupertinoIcons.home),
          title: ("Home"),
          activeColor: CupertinoColors.activeBlue,
          inactiveColor: CupertinoColors.systemGrey,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(CupertinoIcons.settings),
          title: ("Settings"),
          activeColor: CupertinoColors.activeBlue,
          inactiveColor: CupertinoColors.systemGrey,
        ),
      ];
    }

    PersistentTabController _controller;

    _controller = PersistentTabController(initialIndex: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          args.data.name.toUpperCase(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        confineInSafeArea: true,
        backgroundColor: Colors.white,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset:
            true, // This needs to be true if you want to move up the screen when keyboard appears.
        stateManagement: true,
        hideNavigationBarWhenKeyboardShows:
            true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument.
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(10.0),
          colorBehindNavBar: Colors.white,
        ),
        popAllScreensOnTapOfSelectedTab: true,
        popActionScreens: PopActionScreensType.all,
        itemAnimationProperties: ItemAnimationProperties(
          // Navigation Bar's items animation properties.
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimation(
          // Screen transition animation on change of selected tab.
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        ),
        navBarStyle:
            NavBarStyle.style4, // Choose the nav bar style with this property.
      ),
    );
  }
}

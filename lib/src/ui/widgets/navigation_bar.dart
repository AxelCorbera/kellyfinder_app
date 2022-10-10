import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/provider/socket_notifier.dart';
import 'package:app/src/ui/icons/custom_icons.dart';
import 'package:app/src/ui/screens/navigation/nav_chat_screen.dart';
import 'package:app/src/ui/screens/navigation/nav_favorite_screen.dart';
import 'package:app/src/ui/screens/navigation/nav_home_screen.dart';
import 'package:app/src/ui/screens/navigation/nav_profile_screen.dart';
import 'package:app/src/ui/widgets/dialog/custom_dialog.dart';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';

class NavigationBar extends StatefulWidget {
  final int initIndex;
  final bool fromLogin;

  const NavigationBar({Key key, this.initIndex = 0, this.fromLogin = false})
      : super(key: key);

  @override
  _NavigationBarState createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  int _selectedIndex;

  List<Widget> _screens = [
    NavHomeScreen(),
    NavFavoriteScreen(),
    NavChatScreen(),
    NavProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    _selectedIndex = widget.initIndex;

    if (widget.fromLogin)
      Future.delayed(
        Duration(seconds: 1),
        () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomDialog(
                title: AppLocalizations.of(context)
                        .translate("dialogCreateCard1") +
                    "\n \n" +
                    AppLocalizations.of(context)
                        .translate("dialogCreateCard2") +
                    "\n \n" +
                    AppLocalizations.of(context).translate("dialogCreateCard3"),
                hasCancel: false,
              );
            },
          );
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BubbleBottomBar(
        items: <BubbleBottomBarItem>[
          BubbleBottomBarItem(
            backgroundColor: Colors.white,
            icon: Icon(
              MaterialCommunityIcons.home_outline,
              color: Colors.grey[300],
            ),
            activeIcon: Icon(
              MaterialCommunityIcons.home_outline,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              AppLocalizations.of(context).translate("home"),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          BubbleBottomBarItem(
            backgroundColor: Colors.white,
            icon: Icon(
              Icons.favorite_border,
              color: Colors.grey[300],
            ),
            activeIcon: Icon(
              Icons.favorite_border,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              AppLocalizations.of(context).translate("favorites"),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          BubbleBottomBarItem(
            backgroundColor: Colors.white,
            icon: Consumer<SocketNotifier>(
              builder: (context, notifier, child) {
                if (notifier.newChat)
                  return Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Icon(
                        CustomIcons.comments_alt,
                        color: Colors.grey[300],
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  );

                return Icon(
                  CustomIcons.comments_alt,
                  color: Colors.grey[300],
                );
              },
            ),
            activeIcon: Icon(
              CustomIcons.comments_alt,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              AppLocalizations.of(context).translate("chats"),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          BubbleBottomBarItem(
            backgroundColor: Colors.white,
            icon: Icon(
              Icons.person_outline,
              color: Colors.grey[300],
            ),
            activeIcon: Icon(
              Icons.person_outline,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              AppLocalizations.of(context).translate("profile"),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
          )
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        opacity: 1,
        elevation: 8,
        hasNotch: true,
        hasInk: true,
      ),
    );
  }
}

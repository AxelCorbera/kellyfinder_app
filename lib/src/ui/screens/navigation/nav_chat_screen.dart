import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/globals.dart' as globals;
import 'package:app/src/model/user.dart';
import 'package:app/src/provider/chat_notifier.dart';
import 'package:app/src/provider/socket_notifier.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/widgets/button/search_slider_button.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/ui/widgets/lists/chat_list.dart';
import 'package:app/src/utils/constants/searching_type.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NavChatScreen extends StatefulWidget {
  @override
  _NavChatScreenState createState() => _NavChatScreenState();
}

class _NavChatScreenState extends State<NavChatScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future _futureChat;

  @override
  void initState() {
    super.initState();

    User user = Provider.of<UserNotifier>(context, listen: false).user;

    _futureChat = Provider.of<ChatNotifier>(context, listen: false)
        .getUserChats(user, _scaffoldKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(centerTitle:true,
        title: Text(
        AppLocalizations.of(context).translate("chats"),
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {


    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 16),
        SearchSliderButton(
          callback: () {
            setState(() {});
          },
        ),
        Expanded(
          child: FutureBuilder(
            future: _futureChat,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return Consumer<ChatNotifier>(
                    builder: (context, notifier, child) {
                      return ChatList(
                        chats: globals.searchingType == SearchingType.OFFER
                            ? notifier.offerChats
                            : notifier.demandChats,
                      );
                    },
                  );
                }
              }
              return FutureCircularIndicator();
            },
          ),
        )
      ],
    );
  }
}

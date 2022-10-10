import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/user.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/ui/widgets/lists/user_block_list.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:flutter/material.dart';

class BlockedUsersScreen extends StatefulWidget {
  @override
  _BlockedUsersScreenState createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future _futureBlocked;

  List<User> _blockedUsers;

  @override
  void initState() {
    super.initState();

    _futureBlocked = _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(centerTitle:true,
        title: Text(AppLocalizations.of(context).translate("blockedUsers")),
      ),
      body: FutureBuilder(
        future: _futureBlocked,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return UserBlockList(users: _blockedUsers);
            }
          }
          return FutureCircularIndicator();
        },
      ),
    );
  }

  Future _getData() async {
    try {
      _blockedUsers = await ApiProvider().performGetBlockedUsers({});

      return true;
    } catch (e) {
      catchErrors(e, _scaffoldKey);
    }
  }
}

import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/user.dart';
import 'package:app/src/ui/widgets/items/user_block_list_item.dart';
import 'package:app/src/ui/widgets/layout/empty_list_layout.dart';
import 'package:flutter/material.dart';

class UserBlockList extends StatefulWidget {
  final List<User> users;

  const UserBlockList({Key key, this.users}) : super(key: key);

  @override
  _UserBlockListState createState() => _UserBlockListState();
}

class _UserBlockListState extends State<UserBlockList> {
  @override
  Widget build(BuildContext context) {
    if (widget.users?.isNotEmpty ?? false)
      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: widget.users.length,
        itemBuilder: (BuildContext context, int index) {
          return UserBlockListItem(
            user: widget.users[index],
            callback: removeUser,
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        },
      );

    return EmptyListLayout(
      text: AppLocalizations.of(context).translate("noResult"),
    );
  }

  void removeUser(User user) {
    setState(() {
      widget.users.remove(user);
    });
  }
}

import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/user.dart';
import 'package:app/src/ui/widgets/image/network_profile_image.dart';
import 'package:flutter/material.dart';

class UserBlockListItem extends StatelessWidget {
  final User user;
  final Function callback;

  const UserBlockListItem({Key key, this.user, this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: NetworkProfileImage(
        image: user.image,
        width: 48,
        height: 48,
      ),
      title: Text(user.name),
      trailing: FlatButton(
        onPressed: () => _validate(),
        child: Text(
          AppLocalizations.of(context).translate("unblock"),
          style: TextStyle(
            color: Theme.of(context).errorColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future _validate() async {
    try {
      await ApiProvider().performUnblock({"blocked_user": user.id});

      callback(user);

      return true;
    } catch (e) {
      print(e);
      //catchErrors(e, _scaffoldKey);
    }
  }
}

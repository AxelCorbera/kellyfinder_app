import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/provider/socket_notifier.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/screens/profile/blocked_users_screen.dart';
import 'package:app/src/ui/screens/profile/edit_profile_screen.dart';
import 'package:app/src/ui/screens/profile/info_screen.dart';
import 'package:app/src/ui/screens/sign_in/sign_in_screen.dart';
import 'package:app/src/ui/widgets/dialog/custom_dialog.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app/src/config/globals.dart' as globals;

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle:true,
          title: Text(AppLocalizations.of(context).translate("settings"))),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 20),
        ListTile(
          dense: true,
          title: Text(
            AppLocalizations.of(context).translate("editProfile"),
            style: Theme.of(context).textTheme.bodyText2,
          ),
          trailing: Icon(
            Icons.keyboard_arrow_right,
            color: Theme.of(context).primaryColor,
          ),
          onTap: () => navigateTo(context, EditProfileScreen()),
        ),
        ListTile(
          dense: true,
          title: Text(
            AppLocalizations.of(context).translate("blockedUsers"),
            style: Theme.of(context).textTheme.bodyText2,
          ),
          trailing: Icon(
            Icons.keyboard_arrow_right,
            color: Theme.of(context).primaryColor,
          ),
          onTap: () => navigateTo(context, BlockedUsersScreen()),
        ),
        ListTile(
          dense: true,
          title: Text(
            AppLocalizations.of(context).translate("privacyPolitics"),
            style: Theme.of(context).textTheme.bodyText2,
          ),
          trailing: Icon(
            Icons.keyboard_arrow_right,
            color: Theme.of(context).primaryColor,
          ),
          onTap: () {
            _launchURL(globals.policyURL);
          },
        ),
        ListTile(
          dense: true,
          title: Text(
            AppLocalizations.of(context).translate("termsConditions"),
            style: Theme.of(context).textTheme.bodyText2,
          ),
          trailing: Icon(
            Icons.keyboard_arrow_right,
            color: Theme.of(context).primaryColor,
          ),
          onTap: () {
            _launchURL(globals.termsURL);
          },
        ),
        ListTile(
          dense: true,
          title: Text(
            AppLocalizations.of(context).translate("info"),
            style: Theme.of(context).textTheme.bodyText2,
          ),
          trailing: Icon(
            Icons.keyboard_arrow_right,
            color: Theme.of(context).primaryColor,
          ),
          onTap: () => navigateTo(context, InfoScreen()),
        ),
        ListTile(
          dense: true,
          title: Text(
            AppLocalizations.of(context).translate("closeSession"),
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(fontWeight: FontWeight.w600),
          ),
          onTap: () => closeSession(context),
        ),
        ListTile(
          dense: true,
          title: Text(
           AppLocalizations.of(context).translate("removeAccount"),
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(fontWeight: FontWeight.w600),
          ),
          onTap: () => removeAccount(context),
        ),
      ],
    );
  }

  Future closeSession(context) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          title: AppLocalizations.of(context).translate("closeSession"),
        );
      },
    );

    if (result == true) {
      try {
        await ApiProvider().performCloseSession({});

        //Provider.of<SocketNotifier>(context, listen: false).dispose();
        //Provider.of<SocketNotifier>(context, listen: false).disconnectSocket();
      } catch (e) {
        print(e);
      } finally {
        Provider.of<UserNotifier>(context, listen: false).exitUser(context);
        navigateTo(context, SignInScreen(), willPop: true);
      }
    }
  }

  Future removeAccount(context) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          title: AppLocalizations.of(context).translate("sureRemoveAccount"),
        );
      },
    );

    if (result == true) {
      try {
        await ApiProvider().performRemoveAccount({});

        //Provider.of<SocketNotifier>(context, listen: false).dispose();
        //Provider.of<SocketNotifier>(context, listen: false).disconnectSocket();
      } catch (e) {
        print(e);
      } finally {
        Provider.of<UserNotifier>(context, listen: false).exitUser(context);
        navigateTo(context, SignInScreen(nav: "remove"), willPop: true);
      }
    }
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

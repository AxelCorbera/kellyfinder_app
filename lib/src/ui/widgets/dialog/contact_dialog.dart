import 'package:app/src/config/app_localizations.dart';
import 'package:flutter/material.dart';

class ContactDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            AppLocalizations.of(context).translate("willContact"),
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ],
      ),
      actions: <Widget>[
        SimpleDialogOption(
          child: Text(
            AppLocalizations.of(context).translate("accept").toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }
}

import 'package:app/src/config/app_localizations.dart';
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String content;
  final String buttonText;
  final bool hasCancel;

  const CustomDialog(
      {Key key, this.title, this.content, this.buttonText, this.hasCancel = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: (content != null && content != "") ? Text(content) : null,
      actions: <Widget>[
        if (hasCancel)
          SimpleDialogOption(
            child: Text(
              AppLocalizations.of(context).translate("cancel").toUpperCase(),
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
        SimpleDialogOption(
          child: Text(
            buttonText?.toUpperCase() ??
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

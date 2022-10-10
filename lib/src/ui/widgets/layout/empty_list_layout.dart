import 'package:app/src/config/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/src/config/string_casing_extension.dart';

class EmptyListLayout extends StatelessWidget {
  final bool center;
  final String text;

  const EmptyListLayout({Key key, this.center = true, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (center)
      return Center(
        child: Text(
          //AppLocalizations.of(context).translate("noResult"),
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.subtitle1,
        ),
      );
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        //AppLocalizations.of(context).translate("noResult"),
        text,
        style: Theme.of(context).textTheme.subtitle1,
      ),
    );
  }
}

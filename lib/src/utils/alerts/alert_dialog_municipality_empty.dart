import 'package:app/src/config/app_localizations.dart';
import 'package:flutter/material.dart';

Future AlertDialogMunicipalityEmpty(BuildContext context){
  return Future.delayed(Duration(seconds: 0), () async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          AppLocalizations.of(context)
              .translate("notRegisteredMunicipality2"),
        ),
        actions: <Widget>[
          SimpleDialogOption(
            child: Text(
              AppLocalizations.of(context)
                  .translate("accept")
                  .toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    });
  });
}
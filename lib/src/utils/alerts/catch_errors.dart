import 'dart:io';

import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/utils/alerts/handle_snack.dart';
import 'package:app/src/utils/api/api_exception.dart';
import 'package:app/src/utils/form/form_exception.dart';
import 'package:flutter/material.dart';

String _socketError;
String _formatError;

void initErrors(BuildContext context) {
  _socketError = AppLocalizations.of(context).translate("socketError");
  _formatError = AppLocalizations.of(context).translate("formatError");
}

String catchErrors(e, GlobalKey<ScaffoldState> key) {
  String message = 'Error inesperado. pruebe mas tarde.';

  print(e);

  if (e is ApiException) {
    message = e.message;
  } else if (e is FormException) {
    message = e.message;
  } else if (e is SocketException) {
    message = _socketError;
  } else {
    message = _formatError;
  }

  if (key != null) {
    handleSnackBar(key, message);
  }
  return message;
}

import 'package:app/src/config/app_localizations.dart';
import 'package:flutter/cupertino.dart';

String validateEmail(String value, BuildContext context) {
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);

  if (!regex.hasMatch(value))
    return AppLocalizations.of(context).translate("formEmail");
  return null;
}

String validateName(String value, BuildContext context) {
  if (value.isEmpty) return AppLocalizations.of(context).translate("formName");
  return null;
}

String validatePhone(String value, BuildContext context) {
  if (value.isEmpty) return AppLocalizations.of(context).translate("formPhone");

  if(value.length < 7) return AppLocalizations.of(context).translate("formPhone");
  return null;
}

String validatePassword(String value, BuildContext context) {
  if (value.isEmpty)
    return AppLocalizations.of(context).translate("formCharacters");
  if(value.length < 8){
    return AppLocalizations.of(context).translate("formCharacters");
  }
  return null;
}

String validateRepeatPassword(
    String value, String reValue, BuildContext context) {
  if (value != reValue)
    return AppLocalizations.of(context).translate("formPassword");
  return null;
}

String validateDirection(String value, BuildContext context) {
  if (value.isEmpty)
    return AppLocalizations.of(context).translate("formDirection");
  return null;
}

String validateEmpty(String value, BuildContext context) {
  if (value.isEmpty) return AppLocalizations.of(context).translate("formField");
  return null;
}

String validateUrl(String value, BuildContext context) {
  Pattern pattern =
      r'^((?:.|\n)*?)((http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?)';
  RegExp regex = new RegExp(pattern);

  if (!regex.hasMatch(value))
    return AppLocalizations.of(context).translate("municipality_add_festive_invalid_link");
  return null;
}

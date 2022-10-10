import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/sentence_case_text_formatter.dart';
import 'package:app/src/config/string_casing_extension.dart';
import 'package:flutter/material.dart';

class TextFieldDialog extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String buttonText;

  const TextFieldDialog(
      {Key key, this.title, this.buttonText , this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: TextField(
        inputFormatters: [
          SentenceCaseTextFormatter()
        ],
        controller: controller,
        maxLines: 5,
        decoration: InputDecoration(
          labelText:AppLocalizations.of(context).translate("addComment"),
          alignLabelWithHint: true,
          border: OutlineInputBorder()
        ),
      ),
      actions: <Widget>[
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
            buttonText?.toUpperCase() ?? AppLocalizations.of(context).translate("accept").toUpperCase(),
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }
}

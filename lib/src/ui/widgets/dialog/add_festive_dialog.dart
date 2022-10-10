import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/sentence_case_text_formatter.dart';
import 'package:app/src/config/string_casing_extension.dart';
import 'package:app/src/model/event.dart';
import 'package:app/src/ui/widgets/form/location_textfield.dart';
import 'package:app/src/utils/form/form_validate.dart';
import 'package:flutter/material.dart';

class AddFestiveDialog extends StatefulWidget {
  @override
  _AddFestiveDialogState createState() => _AddFestiveDialogState();
}

class _AddFestiveDialogState extends State<AddFestiveDialog> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameController;
  TextEditingController _linkController;

  @override
  void initState() {
    _nameController = TextEditingController();
    _linkController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _linkController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      titlePadding: EdgeInsets.all(16),
      title: Text(AppLocalizations.of(context).translate("addFestive")),
      content: Container(
        width: MediaQuery.of(context).size.width,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                inputFormatters: [
                  SentenceCaseTextFormatter(),
                ],
                controller: _nameController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context).translate("festiveName"),
                  filled: true,
                ),
                validator: (value) => validateEmpty(value, context),
              ),
              SizedBox(height: 8),
              TextFormField(
                inputFormatters: [
                ],
                controller: _linkController,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).translate("link"),
                  filled: true,
                ),
                //validator: (value) => validateUrl(value, context),
                validator: (value){
                  if(value.isNotEmpty){
                    return validateUrl(value, context);
                  }

                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(AppLocalizations.of(context).translate("addLink"))
            ],
          ),
        ),
      ),
      actions: <Widget>[
        SimpleDialogOption(
          child: Text(
            AppLocalizations.of(context).translate("cancel").toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        SimpleDialogOption(
          child: Text(
            AppLocalizations.of(context).translate("accept").toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            if (_formKey.currentState.validate()) {
              Navigator.pop(
                context,
                Event(name: _nameController.text, link: _linkController.text),
              );
            }
          },
        ),
      ],
    );
  }
}

import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/sentence_case_text_formatter.dart';
import 'package:app/src/config/string_casing_extension.dart';
import 'package:app/src/model/municipality/recommended_visit.dart';
import 'package:app/src/ui/widgets/form/location_textfield.dart';
import 'package:app/src/utils/form/form_validate.dart';
import 'package:flutter/material.dart';

class AddVisitDialog extends StatefulWidget {
  @override
  _AddVisitDialogState createState() => _AddVisitDialogState();
}

class _AddVisitDialogState extends State<AddVisitDialog> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameController;
  TextEditingController _locationController;

  Map _mapInfo = {};

  @override
  void initState() {
    _nameController = TextEditingController();
    _locationController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      titlePadding: EdgeInsets.all(16),
      title: Text(AppLocalizations.of(context).translate("addRecommendedVisit")),
      content: Container(
        width: MediaQuery.of(context).size.width,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                inputFormatters: [
                  SentenceCaseTextFormatter()
                ],
                controller: _nameController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText:AppLocalizations.of(context).translate("siteName"),
                  filled: true,
                ),
                validator: (value) => validateEmpty(value, context),
              ),
              SizedBox(height: 8),
              LocationTextField(
                controller: _locationController,
                mapInfo: _mapInfo,
                isCompany: true, // forzar que se puedan introducir direcciones completas, no solo ciudades
                padding: EdgeInsets.all(0),
                mustValidate: false,
                callback: (address) {
                  setState(() {
                    _locationController.text = address;
                  });
                },
              ),
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
              Navigator.pop(context, RecommendedVisit(
                  name: _nameController.text.trim(),
                  lat: _mapInfo['lat'],
                  lng: _mapInfo['long'],
                  address: _locationController.text.trim()));
            }
          },
        ),
      ],
    );
  }
}

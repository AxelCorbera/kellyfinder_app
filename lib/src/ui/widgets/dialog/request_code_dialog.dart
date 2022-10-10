import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/sentence_case_text_formatter.dart';
import 'package:app/src/config/string_casing_extension.dart';
import 'package:app/src/model/municipality/municipality.dart';
import 'package:app/src/ui/widgets/dialog/custom_dialog.dart';
import 'package:app/src/utils/api/api_exception.dart';
import 'package:app/src/utils/form/form_validate.dart';
import 'package:flutter/material.dart';

class RequestCodeDialog extends StatefulWidget {
  final Municipality municipality;

  const RequestCodeDialog({Key key, this.municipality}) : super(key: key);

  @override
  _RequestCodeDialogState createState() => _RequestCodeDialogState();
}

class _RequestCodeDialogState extends State<RequestCodeDialog> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _emailController;
  TextEditingController _phoneController;
  TextEditingController _contactController;

  @override
  void initState() {
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _contactController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                AppLocalizations.of(context).translate("addInfoToRequest"),
                style: Theme.of(context).textTheme.bodyText2,
              ),
              SizedBox(height: 16),
              TextFormField(
                inputFormatters: [
                  //SentenceCaseTextFormatter(),
                ],
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).translate("email"),
                  fillColor: Theme.of(context).disabledColor,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) => validateEmpty(value, context),
              ),
              SizedBox(height: 16),
              TextFormField(
                inputFormatters: [],
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).translate("phone"),
                  fillColor: Theme.of(context).disabledColor,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) => validateEmpty(value, context),
              ),
              SizedBox(height: 16),
              TextFormField(
                inputFormatters: [
                  SentenceCaseTextFormatter()
                ],
                controller: _contactController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context).translate("contactPerson"),
                  fillColor: Theme.of(context).disabledColor,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) => validateEmpty(value, context),
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
            Navigator.pop(context, false);
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
          onPressed: () async {
            if (_formKey.currentState.validate()) {
              _requestCustomCode();
            }
          },
        ),
      ],
    );
  }

  void _requestCustomCode() async {
    try {
      var response = await ApiProvider().requestCustomCode({
        "municipality_id": widget.municipality.id,
        "name": _contactController.text.trim(),
        "email": _emailController.text.trim(),
        "phone": _phoneController.text.trim()
      });

      print(response);

      Navigator.pop(context, true);
    } on ApiException catch(e){
      if(e.code == 32002){
        // Código ya solicitado
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialog(
              title: e.message,
              hasCancel: false,
            );
          },
        );
      }
    }
  }
}

import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/municipality/municipality.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/widgets/dialog/custom_dialog.dart';
import 'package:app/src/utils/api/api_exception.dart';
import 'package:app/src/utils/form/form_validate.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddCodeDialog extends StatefulWidget {
  final Municipality municipality;

  AddCodeDialog({this.municipality});

  @override
  _AddCodeDialogState createState() => _AddCodeDialogState();
}

class _AddCodeDialogState extends State<AddCodeDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              AppLocalizations.of(context).translate("addEmailCode"),
              style: Theme.of(context).textTheme.bodyText2,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).translate("addCode"),
                fillColor: Theme.of(context).disabledColor,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
              validator: (value) => validateEmpty(value, context),
            ),
            SizedBox(height: 16),
            RichText(
              text: TextSpan(
                text:
                    "${AppLocalizations.of(context).translate("haveNoCode")} ",
                style: Theme.of(context).textTheme.bodyText2,
                children: <TextSpan>[
                  TextSpan(
                    text: AppLocalizations.of(context).translate("requestCode"),
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        await _requestCode();
                      },
                  ),
                ],
              ),
            ),
          ],
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
            Navigator.pop(context, 0);
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
              await _validateCode();
            }
          },
        ),
      ],
    );
  }

  _validateCode() async {
    try {
      await ApiProvider().validateCode({
        "municipality_id": widget.municipality.id,
        "code": _controller.text
      });

      Navigator.pop(context, 1);
    } on ApiException catch(e){

      if(e.code == 32000){
        // Código no válido
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialog(
              title: e.message,
              hasCancel: false,
            );
          },
        );

        setState(() {
          _controller.clear();
        });
      }

      if(e.code == 32001){
        // Código caducado
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialog(
              title: e.message,
              hasCancel: false,
            );
          },
        );

        setState(() {
          _controller.clear();
        });
      }
      //Navigator.pop(context, 1);
    }
  }

  _requestCode() async {
    try {
      var response = await ApiProvider()
          .requestCode({"municipality_id": widget.municipality.id});

      print(response);

      final result = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return SentCodeDialog();
          });

      if (result == false) {
        // Solicitar código custom
        Navigator.pop(context, 2);
      }
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

class SentCodeDialog extends StatefulWidget {
  @override
  _SentCodeDialogState createState() => _SentCodeDialogState();
}

class _SentCodeDialogState extends State<SentCodeDialog> {
  @override
  void initState() {
    /*Future.delayed(Duration(seconds: 1), () {
      String email =
          Provider.of<UserNotifier>(context, listen: false).user.email;

      ApiProvider().sendCodeEmail({"email": email});
    });*/

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String email = Provider.of<UserNotifier>(context, listen: false).user.email;

    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            //"${AppLocalizations.of(context).translate("emailSent")} $email",
            AppLocalizations.of(context).translate("emailSent"),
            style: Theme.of(context).textTheme.bodyText2,
          ),
          SizedBox(height: 16),
          InkWell(
            onTap: () {
              Navigator.pop(context, false);
            },
            child: Text(
              AppLocalizations.of(context).translate("incorrectEmail"),
              style: Theme.of(context).textTheme.subtitle2.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
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

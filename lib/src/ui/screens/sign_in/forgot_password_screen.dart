import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/sentence_case_text_formatter.dart';
import 'package:app/src/ui/widgets/button/custom_future_button.dart';
import 'package:app/src/ui/widgets/image/custom_logo.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/form/form_validate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _emailController;

  Future _futureForgot;

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(centerTitle:true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Form(
                key: _formKey,
                child: _buildForm(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 40),
        Center(child: CustomLogo()),
        ListTile(
          title: Text(
            AppLocalizations.of(context).translate("helpRecover"),
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        ListTile(
          title: Text(
            AppLocalizations.of(context).translate("addEmailToRecover"),
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ),
        ListTile(
          title: TextFormField(
            inputFormatters: [],
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate("email"),
              hintText: AppLocalizations.of(context).translate("emailExample"),
              fillColor: Theme.of(context).disabledColor,
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: (value) => validateEmail(value, context),
          ),
        ),
        SizedBox(height: 60),
        Center(
          child: CustomFutureButton(
            text: AppLocalizations.of(context).translate("send"),
            future: _futureForgot,
            callback: () async {
              setState(() {
                _futureForgot = _validate();
              });
            },
          ),
        ),
      ],
    );
  }

  Future _validate() async {
    if (_formKey.currentState.validate()) {
      try {
        await ApiProvider().performForgot({
          "email": _emailController.text,
        });

        Navigator.pop(context);
      } catch (e) {
        catchErrors(e, _scaffoldKey);
      }
    }
  }
}

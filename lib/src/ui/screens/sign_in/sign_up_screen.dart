import 'dart:convert';
import 'dart:developer';

import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/sentence_case_text_formatter.dart';
import 'package:app/src/config/sentence_words_text_formatter.dart';
import 'package:app/src/model/user.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/smtp_server/mailer.dart';
import 'package:app/src/ui/screens/sign_in/add_location_screen.dart';
import 'package:app/src/ui/widgets/button/custom_future_button.dart';
import 'package:app/src/ui/widgets/image/custom_logo.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/form/form_validate.dart';
import 'package:app/src/utils/get_device_info.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app/src/config/globals.dart' as globals;

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _nameController;
  TextEditingController _emailController;
  TextEditingController _passwordController;
  TextEditingController _raffleController;

  FocusNode _emailNode;
  FocusNode _passNode;

  FocusNode _raffleNode;

  bool _obscure;
  bool _accept;

  Future _futureSignUp;

  bool _acceptError;

  bool _raffleActive = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _raffleController = TextEditingController();

    _emailNode = FocusNode();
    _passNode = FocusNode();
    _raffleNode = FocusNode();

    _obscure = true;
    _accept = false;

    _acceptError = false;

    _checkRaffle();
  }

  @override
  void dispose() {
    super.dispose();

    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _raffleController.dispose();

    _emailNode.dispose();
    _passNode.dispose();
    _raffleNode.dispose();
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
            AppLocalizations.of(context).translate("welcome"),
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        ListTile(
          title: TextFormField(
            controller: _nameController,
            keyboardType: TextInputType.text,
            //maxLength: 190,
            inputFormatters: [
              LengthLimitingTextInputFormatter(190),
              FilteringTextInputFormatter.deny(RegExp("[0-9]")),
              SentenceWordsTextFormatter()
            ],
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate("nameSurname"),
              fillColor: Theme.of(context).disabledColor,
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: (value) => validateName(value, context),
            onFieldSubmitted: (value) => _emailNode.requestFocus(),
          ),
        ),
        ListTile(
          title: TextFormField(
            controller: _emailController,
            inputFormatters: [],
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            focusNode: _emailNode,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate("email"),
              hintText: AppLocalizations.of(context).translate("emailExample"),
              fillColor: Theme.of(context).disabledColor,
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: (value) => validateEmail(value, context),
            onFieldSubmitted: (value) => _passNode.requestFocus(),
          ),
        ),
        ListTile(
          title: TextFormField(
            controller: _passwordController,
            obscureText: _obscure,
            keyboardType: TextInputType.visiblePassword,
            //textInputAction: TextInputAction.done,
            textInputAction: TextInputAction.next,
            focusNode: _passNode,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate("password"),
              fillColor: Theme.of(context).disabledColor,
              filled: true,
              suffixIcon: IconButton(
                icon: Icon(Icons.visibility),
                onPressed: () {
                  setState(() {
                    _obscure = !_obscure;
                  });
                },
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: (value) => validatePassword(value, context),
            onFieldSubmitted: (value) => _raffleNode.requestFocus(),
          ),
        ),
        if (_raffleActive)
          ListTile(
            title: TextFormField(
              inputFormatters: [],
              controller: _raffleController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              focusNode: _raffleNode,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)
                    .translate("signup_raffle_code"),
                fillColor: Theme.of(context).disabledColor,
                filled: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        SizedBox(height: 8.0,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: <Widget>[
              Checkbox(
                  activeColor: Theme.of(context).buttonColor,
                  value: _accept,
                  onChanged: (value) {
                    setState(() {
                      _accept = !_accept;
                    });
                  }),
              Expanded(
                child: GestureDetector(
                  onTap: (){
                    _launchURL(globals.policyAndLegalURL);
                  },
                  child: RichText(
                    text: TextSpan(
                        text:
                        AppLocalizations.of(context).translate("sign_up_terms_read") + " ",
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                          //decoration: TextDecoration.underline,
                          color: _acceptError ? Colors.red : null,
                        ),
                        children: [
                          TextSpan(
                            text: AppLocalizations.of(context).translate("sign_up_terms_and_conditions") + " ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                            recognizer: new TapGestureRecognizer()
                              ..onTap = () => showTerms(),
                          ),
                          new TextSpan(
                            text: AppLocalizations.of(context).translate("sign_up_terms_and") + " ",
                          ),
                          TextSpan(
                            text: AppLocalizations.of(context).translate("sign_up_terms_policy") + " ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                            recognizer: new TapGestureRecognizer()
                              ..onTap = () => showPolicy(),
                          ),
                        ]),
                  ),
                  /*child: Text(
                    AppLocalizations.of(context).translate("readTerms"),
                    textAlign: TextAlign.justify,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                      decoration: TextDecoration.underline,
                      color: _acceptError ? Colors.red : null,
                    ),
                  ),*/
                ),
              )
            ],
          ),
        ),
        SizedBox(height: 12),
        Center(
          child: CustomFutureButton(
            future: _futureSignUp,
            text: AppLocalizations.of(context).translate("signIn"),
            callback: () async {
              setState(() {
                _futureSignUp = _validate();
              });
            },
          ),
        ),
        SizedBox(height: 12),
      ],
    );
  }

  Future _validate() async {
    if (_formKey.currentState.validate()) {
      if (_accept) {
        _acceptError = false;

        try {
          AppUser appUser = await ApiProvider().performSignUp({
            "name": _nameController.text,
            "email": _emailController.text,
            "password": _passwordController.text,
            "lottery_friend_code": _raffleController.text
          });

          final response =
          await ApiProvider().performNumLotery(appUser.user.id.toString());
          log(response);
          var json = jsonDecode(response);
          log(json['num_loteria']);
          String code = json['num_loteria'];
          await sendEmailTest(code,_emailController.text);

          await Provider.of<UserNotifier>(context, listen: false)
              .initUser(appUser);

          Provider.of<UserNotifier>(context, listen: false).getCards();

          Provider.of<UserNotifier>(context, listen: false)
              .initUserSocket(context);

          getDeviceInfo();

          navigateTo(context, AddLocationScreen(), willPop: true);
        } catch (e) {
          catchErrors(e, _scaffoldKey);
        }
      } else {
        setState(() {
          _acceptError = true;
        });
      }
    }
  }

  Future<void> sendEmailTest(String code, String email) async {
    await Mailer(code, email);
  }

  Future _checkRaffle() async {
    final result = await ApiProvider().performIsLotteryActive({});

    setState(() {
      _raffleActive = result['is_active'];
    });
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  showTerms() {
    _launchURL(globals.termsURL);
  }

  showPolicy() {
    _launchURL(globals.policyURL);
  }
}

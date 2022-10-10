import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/sentence_case_text_formatter.dart';
import 'package:app/src/model/user.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/screens/sign_in/forgot_password_screen.dart';
import 'package:app/src/ui/screens/sign_in/sign_up_screen.dart';
import 'package:app/src/ui/widgets/button/custom_future_button.dart';
import 'package:app/src/ui/widgets/dialog/custom_dialog.dart';
import 'package:app/src/ui/widgets/image/custom_logo.dart';
import 'package:app/src/ui/widgets/navigation_bar.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/form/form_validate.dart';
import 'package:app/src/utils/get_device_info.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/src/utils/cache/preferences.dart';

class SignInScreen extends StatefulWidget {
  final String nav;

  const SignInScreen({Key key, this.nav}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _emailController;
  TextEditingController _passwordController;

  FocusNode _passNode;

  bool _obscure;

  Future _futureSignIn;

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    _passNode = FocusNode();

    _obscure = true;

    if (widget.nav == "remove") {
      Future.delayed(Duration(seconds: 1), () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialog(
              title: AppLocalizations.of(context).translate("removedCorrect"),
              hasCancel: false,
            );
          },
        );
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    _passNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
            AppLocalizations.of(context).translate("intro"),
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        ListTile(
          title: TextFormField(
            inputFormatters: [],
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
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
            textInputAction: TextInputAction.done,
            focusNode: _passNode,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate("password"),
              fillColor: Theme.of(context).disabledColor,
              filled: true,
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.visibility,
                  size: 16,
                ),
                onPressed: () {
                  setState(() {
                    _obscure = !_obscure;
                  });
                },
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: (value) => value.isEmpty
                ? AppLocalizations.of(context).translate("addPassword")
                : null,
          ),
        ),
        ListTile(
          title: Center(
            child: InkWell(
              onTap: () => navigateTo(context, ForgotPasswordScreen()),
              child: Container(
                padding: const EdgeInsets.all(6),
                child: RichText(
                  text: TextSpan(
                    text:
                        '${AppLocalizations.of(context).translate("forgotPassword")} ',
                    style: Theme.of(context).textTheme.bodyText2,
                    children: <TextSpan>[
                      TextSpan(
                        text: AppLocalizations.of(context).translate("recover"),
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 40),
        Center(
          child: CustomFutureButton(
            future: _futureSignIn,
            text: AppLocalizations.of(context).translate("signIn"),
            callback: () async {
              setState(() {
                _futureSignIn = _validate();
              });
            },
          ),
        ),
        ListTile(
          title: Center(
            child: InkWell(
              onTap: () => navigateTo(context, SignUpScreen()),
              child: Container(
                padding: const EdgeInsets.all(6),
                child: RichText(
                  text: TextSpan(
                    text:
                        '${AppLocalizations.of(context).translate("noAccount")} ',
                    style: Theme.of(context).textTheme.bodyText2,
                    children: <TextSpan>[
                      TextSpan(
                        text:
                            AppLocalizations.of(context).translate("register"),
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Future _validate() async {
    if (_formKey.currentState.validate()) {
      try {
        AppUser appUser = await ApiProvider().performSignIn({
          "email": _emailController.text,
          "password": _passwordController.text,
        });

        //Preferences.saveSharedUser(appUser); sin esta línea no guarda la sesión del user

        await Provider.of<UserNotifier>(context, listen: false)
            .initUser(appUser);

        Provider.of<UserNotifier>(context, listen: false).getCards();

        Provider.of<UserNotifier>(context, listen: false)
            .initUserSocket(context);

        getDeviceInfo();

        navigateTo(context, NavigationBar(fromLogin: true), willPop: true);
      } catch (e) {
        catchErrors(e, _scaffoldKey);
      }
    }
  }
}

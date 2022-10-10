import 'dart:io';

import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/sentence_case_text_formatter.dart';
import 'package:app/src/config/sentence_words_text_formatter.dart';
import 'package:app/src/config/string_casing_extension.dart';
import 'package:app/src/model/user.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/widgets/image/file_profile_image.dart';
import 'package:app/src/ui/widgets/image/network_profile_image.dart';
import 'package:app/src/ui/widgets/indicators/future_linear_indicator.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/form/form_validate.dart';
import 'package:app/src/utils/media/handle_image_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameController;
  TextEditingController _emailController;

  FocusNode _emailNode;

  File _image;

  String _url;

  bool _isLoading;

  @override
  void initState() {
    super.initState();

    User user = Provider.of<UserNotifier>(context, listen: false).user;

    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);

    _url = user.image;

    _emailNode = FocusNode();

    _isLoading = false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();

    _emailNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(centerTitle:true,
        title: Text(AppLocalizations.of(context).translate("editProfile")),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () {
              _validate();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_isLoading ? 8 : 0),
          child: _isLoading ? FutureLinearIndicator() : Container(),
        ),
      ),
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
      children: <Widget>[
        SizedBox(height: 20),
        _image != null
            ? FileProfileImage(
                image: _image,
                width: 80,
                height: 80,
              )
            : NetworkProfileImage(
                image: _url,
                width: 80,
                height: 80,
              ),
        FlatButton(
          onPressed: () async {
            _image = await handleImageDialog(context);
            setState(() {});
          },
          child: Text(
            AppLocalizations.of(context).translate("changeProfilePhoto"),
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .copyWith(color: Theme.of(context).primaryColor),
          ),
        ),
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          title: TextFormField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              LengthLimitingTextInputFormatter(190),
              FilteringTextInputFormatter.deny(RegExp("[0-9]")),
              SentenceWordsTextFormatter()
            ],
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          title: TextFormField(
            controller: _emailController,
            focusNode: _emailNode,
            inputFormatters: [
              //SentenceCaseTextFormatter(),
            ],
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate("email"),
              fillColor: Theme.of(context).disabledColor,
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: (value) => validateEmail(value, context),
          ),
        ),
      ],
    );
  }

  Future _validate() async {
    if (_formKey.currentState.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });

        await Future.delayed(Duration(seconds: 3));

        User user = await ApiProvider().performEditProfile(
          {"name": _nameController.text, "email": _emailController.text},
          _image,
        );

        Provider.of<UserNotifier>(context, listen: false).editUser(user);

        Navigator.pop(context);
      } catch (e) {
        catchErrors(e, _scaffoldKey);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

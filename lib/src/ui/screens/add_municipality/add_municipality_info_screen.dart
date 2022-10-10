import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/sentence_case_text_formatter.dart';
import 'package:app/src/config/sentence_words_text_formatter.dart';
import 'package:app/src/config/string_casing_extension.dart';
import 'package:app/src/model/municipality/municipality.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/screens/municipality/edit_municipality_screen.dart';
import 'package:app/src/ui/widgets/button/custom_button.dart';
import 'package:app/src/ui/widgets/dialog/add_code_dialog.dart';
import 'package:app/src/ui/widgets/dialog/contact_dialog.dart';
import 'package:app/src/ui/widgets/dialog/request_code_dialog.dart';
import 'package:app/src/ui/widgets/form/location_textfield.dart';
import 'package:app/src/utils/form/form_validate.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'add_municipality_presentation_screen.dart';

class AddMunicipalityInfoScreen extends StatefulWidget {
  final Municipality municipality;
  final bool isCreating;

  const AddMunicipalityInfoScreen(
      {Key key, this.municipality, this.isCreating = false})
      : super(key: key);

  @override
  _AddMunicipalityInfoScreenState createState() =>
      _AddMunicipalityInfoScreenState();
}

class _AddMunicipalityInfoScreenState extends State<AddMunicipalityInfoScreen> {
  bool _isDataSaved = false;

  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameController;
  TextEditingController _mayorController;
  TextEditingController _populationController;
  TextEditingController _phoneController;
  TextEditingController _emailController;
  TextEditingController _locationController;
  TextEditingController _partyController;
  TextEditingController _elevationController;

  FocusNode _mayorNode;
  FocusNode _populationNode;
  FocusNode _phoneNode;
  FocusNode _emailNode;
  FocusNode _partyNode;
  FocusNode _elevationNode;

  Map _mapInfo = {};

  @override
  void initState() {
    if (widget.municipality?.name != null) {
      _nameController = TextEditingController(text: widget.municipality.name);
    } else {
      _nameController = TextEditingController();
    }

    _mayorController = TextEditingController();
    _populationController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _locationController = TextEditingController();
    _partyController = TextEditingController();
    _elevationController = TextEditingController();

    Future.delayed(Duration.zero, () {
      if (Provider.of<UserNotifier>(context, listen: false)
              .appUser
              .municipality !=
          null) {
        fillMunicipalityInfo();
      }
    });

    _mayorNode = FocusNode();
    _populationNode = FocusNode();
    _phoneNode = FocusNode();
    _emailNode = FocusNode();
    _partyNode = FocusNode();
    _elevationNode = FocusNode();

    showCodeDialogs();

    super.initState();
  }

  void fillMunicipalityInfo() {
    setState(() {
      _nameController = TextEditingController(
          text: Provider.of<UserNotifier>(context, listen: false)
              .appUser
              .municipality
              .customName);
      _mayorController = TextEditingController(
          text: Provider.of<UserNotifier>(context, listen: false)
              .appUser
              .municipality
              .major);
      _populationController = TextEditingController(
          text: Provider.of<UserNotifier>(context, listen: false)
              .appUser
              .municipality
              .population
              .toString());
      _phoneController = TextEditingController(
          text: Provider.of<UserNotifier>(context, listen: false)
              .appUser
              .municipality
              .phone);
      _emailController = TextEditingController(
          text: Provider.of<UserNotifier>(context, listen: false)
              .appUser
              .municipality
              .email);
      _locationController = TextEditingController(
          text: Provider.of<UserNotifier>(context, listen: false)
              .appUser
              .municipality
              .directionTownHall);
      _mapInfo['lat'] = Provider.of<UserNotifier>(context, listen: false)
          .appUser
          .municipality
          .lat;
      _mapInfo['long'] = Provider.of<UserNotifier>(context, listen: false)
          .appUser
          .municipality
          .lng;
      _partyController = TextEditingController(
          text: Provider.of<UserNotifier>(context, listen: false)
              .appUser
              .municipality
              .politicalParty);
      _elevationController = TextEditingController(
          text: Provider.of<UserNotifier>(context, listen: false)
              .appUser
              .municipality
              .elevation
              .toString());
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mayorController.dispose();
    _populationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _partyController.dispose();
    _elevationController.dispose();

    _mayorNode.dispose();
    _populationNode.dispose();
    _phoneNode.dispose();
    _emailNode.dispose();
    _partyNode.dispose();
    _elevationNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isDataSaved) {
          while (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          navigateTo(context, EditMunicipalityScreen());

          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context).translate("publishMunicipality"),
          ),
        ),
        body: Form(key: _formKey, child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(
                AppLocalizations.of(context).translate("municipality"),
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                    color: Theme.of(context).primaryColorLight,
                    fontWeight: FontWeight.w600),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              title: TextFormField(
                inputFormatters: [
                  SentenceWordsTextFormatter()
                ],
                controller: _nameController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)
                      .translate("municipalityName"),
                  fillColor: Theme.of(context).disabledColor,
                  filled: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) => validateEmpty(value, context),
                onFieldSubmitted: (value) => _mayorNode.requestFocus(),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              title: TextFormField(
                inputFormatters: [
                  SentenceWordsTextFormatter()
                ],
                controller: _mayorController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                focusNode: _mayorNode,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).translate("mayor"),
                  fillColor: Theme.of(context).disabledColor,
                  filled: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) => validateEmpty(value, context),
                onFieldSubmitted: (value) => _populationNode.requestFocus(),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              title: TextFormField(
                controller: _populationController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                ],
                focusNode: _populationNode,
                decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context).translate("population"),
                  fillColor: Theme.of(context).disabledColor,
                  filled: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) => validateEmpty(value, context),
                onFieldSubmitted: (value) => _phoneNode.requestFocus(),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              title: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(15),
                ],
                focusNode: _phoneNode,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).translate("phone"),
                  fillColor: Theme.of(context).disabledColor,
                  filled: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) => validatePhone(value, context),
                onFieldSubmitted: (value) => _emailNode.requestFocus(),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              title: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                focusNode: _emailNode,
                inputFormatters: [],
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).translate("email"),
                  fillColor: Theme.of(context).disabledColor,
                  filled: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) => validateEmail(value, context),
                onFieldSubmitted: (value) => _partyNode.requestFocus(),
              ),
            ),
            LocationTextField(
              controller: _locationController,
              text: AppLocalizations.of(context).translate("townHallLocation"),
              mapInfo: _mapInfo,
              isCompany: true, //para que se muestren direcciones con calle
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              callback: (address) {
                setState(() {
                  _locationController.text = address;
                });
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              title: TextFormField(
                inputFormatters: [
                  SentenceCaseTextFormatter()
                ],
                controller: _partyController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                focusNode: _partyNode,
                decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context).translate("politicParty"),
                  fillColor: Theme.of(context).disabledColor,
                  filled: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) => validateEmpty(value, context),
                onFieldSubmitted: (value) => _elevationNode.requestFocus(),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              title: TextFormField(
                controller: _elevationController,
                keyboardType: TextInputType.numberWithOptions(decimal: false),
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                ],
                focusNode: _elevationNode,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)
                      .translate("add_municipality_info_screen_elevation"),
                  fillColor: Theme.of(context).disabledColor,
                  filled: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) => validateEmpty(value, context),
              ),
            ),
            SizedBox(height: 16),
            CustomButton(
              text: AppLocalizations.of(context).translate("save"),
              function: _validate,
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future _validate() async {
    if (_formKey.currentState.validate()) {
      // Crear municipio info
      final result = await ApiProvider().createMunicipality({
        "id": widget.municipality.id,
        "name": _nameController.text.trim(),
        "major": _mayorController.text.trim(),
        "email": _emailController.text.trim(),
        "population": _populationController.text.trim(),
        "phone": _phoneController.text.trim(),
        "lat": _mapInfo['lat'],
        "lng": _mapInfo['long'],
        "direction_town_hall": _locationController.text.trim(),
        "video": null,
        "political_party": _partyController.text.trim(),
        "elevation": _elevationController.text.trim()
      }, [], null);

      Municipality newMunicipality = Municipality.fromJson(result);

      _isDataSaved = true;

      if (widget.isCreating) {
        navigateTo(
            context,
            AddMunicipalityPresentationScreen(
              isCreating: widget.isCreating,
            ));
      } else {
        Navigator.pop(context);
      }

      // Guardar municipio en AppUser
      Provider.of<UserNotifier>(context, listen: false)
          .setUserMunicipality(newMunicipality);
    } else {
      setState(() {});
    }
  }

  void showCodeDialogs() {
    Future.delayed(Duration(seconds: 0), () async {
      Municipality municipality =
          Provider.of<UserNotifier>(context, listen: false)
              .appUser
              .municipality;

      if (municipality == null) {
        final result = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddCodeDialog(
                municipality: widget.municipality,
              );
            });

        if (result == 1) {
        } else if (result == 2) {
          final result = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return RequestCodeDialog(municipality: widget.municipality);
              });

          if (result == true)
            await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ContactDialog();
                });

          Navigator.pop(context);
        } else
          Navigator.pop(context);
      }
    });
  }
}

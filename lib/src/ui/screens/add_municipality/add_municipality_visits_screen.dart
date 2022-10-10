import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/app_styles.dart';
import 'package:app/src/model/municipality/municipality.dart';
import 'package:app/src/model/municipality/recommended_visit.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/screens/add_municipality/add_municipality_festive_screen.dart';
import 'package:app/src/ui/screens/add_municipality/add_municipality_sites_screen.dart';
import 'package:app/src/ui/widgets/button/custom_button.dart';
import 'package:app/src/ui/widgets/dialog/add_visit_dialog.dart';
import 'package:app/src/ui/widgets/dialog/custom_dialog.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:app/src/config/string_casing_extension.dart';
import 'package:provider/provider.dart';

class AddMunicipalityVisitsScreen extends StatefulWidget {
  final bool isCreating;

  AddMunicipalityVisitsScreen({this.isCreating = false});

  @override
  _AddMunicipalityVisitsScreenState createState() =>
      _AddMunicipalityVisitsScreenState();
}

class _AddMunicipalityVisitsScreenState
    extends State<AddMunicipalityVisitsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  Future _futureVisits;

  List<RecommendedVisit> _visits = [];

  @override
  void initState() {
    super.initState();

    _futureVisits = getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title:
            Text(AppLocalizations.of(context).translate("publishMunicipality")),
      ),
      body: FutureBuilder(
        future: _futureVisits,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return _buildBody();
            }
          }
          return FutureCircularIndicator();
        },
      ),
//      body: _buildBody(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CustomButton(
        text: widget.isCreating
            ? AppLocalizations.of(context).translate("next")
            : AppLocalizations.of(context)
                .translate("municipality_graphic_report_back"),
        function: () async {
          if (widget.isCreating) {
            await navigateTo(
              context,
              AddMunicipalitySitesScreen(),
              isWaiting: true,
            );
            navigateTo(context, AddMunicipalityFestiveScreen(isCreating: widget.isCreating,));
          } else {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _buildBody() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              title: Text(
                AppLocalizations.of(context).translate("recommendedVisits"),
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                    color: Theme.of(context).primaryColorLight,
                    fontWeight: FontWeight.w600),
              ),
            ),
            if (_visits.isEmpty)
              ListTile(
                title: Text(
                  AppLocalizations.of(context).translate("noVisits"),
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ),
            if (_visits.isNotEmpty) _buildList(),
            _buildButton(),
            SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _visits.length,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: <Widget>[
            ListTile(
              dense: true,
              title: Text(
                AppLocalizations.of(context).translate("siteName"),
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(color: AppStyles.lightGreyColor),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _visits[index].name,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.close),
                onPressed: () async {

                  final result = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomDialog(
                        title: AppLocalizations.of(context).translate("municipality_recommended_visits_delete_confirmation_text"),
                        buttonText: AppLocalizations.of(context).translate("accept"),
                      );
                    },
                  );

                  if(result){
                    _deleteRecommendedVisit(_visits[index].id);

                    setState(() {
                      _visits.removeAt(index);
                    });
                  }
                },
              ),
            ),
            ListTile(
              dense: true,
              title: Text(
                AppLocalizations.of(context).translate("location"),
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(color: AppStyles.lightGreyColor),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _visits[index].address != "" ? _visits[index].address : "-",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
            ),
          ],
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(color: AppStyles.lightGreyColor);
      },
    );
  }

  Widget _buildButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: FlatButton.icon(
        padding: EdgeInsets.all(4),
        onPressed: () async {
          final result = await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AddVisitDialog();
              });

          if (result != null){

            RecommendedVisit rv = await _createRecommendedVisit(result);

            setState(() {
              _visits.add(rv);
            });

          }
        },
        icon: Icon(
          Icons.add,
          size: 24,
          color: Theme.of(context).primaryColor,
        ),
        label: Text(
          AppLocalizations.of(context).translate("addVisit"),
          style: Theme.of(context).textTheme.subtitle1.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  Future<RecommendedVisit> _createRecommendedVisit(RecommendedVisit visit) async {
    try {
      RecommendedVisit result = await ApiProvider().createRecommendedVisit(
          {
            "name": visit.name,
            "lat": visit.lat,
            "lng": visit.lng,
            "direction": visit.address
          },
          Provider.of<UserNotifier>(context, listen: false)
              .appUser
              .municipality
              .id);

      print(result);
      print(result.id);

      return result;
    } catch (e) {
      catchErrors(e, _scaffoldKey);
    }
  }

  Future getData() async {
    try {
      _visits = await ApiProvider().getRecommendedVisits(
          {},
          Provider.of<UserNotifier>(context, listen: false)
              .appUser
              .municipality
              .id);

      return true;
    } catch (e) {
      catchErrors(e, _scaffoldKey);
    }
  }

  _deleteRecommendedVisit(int recommendedVisitId) async {
    try {
      var result =
      await ApiProvider().deleteRecommendedVisit({}, recommendedVisitId);

      print(result);
    } catch (e) {
      catchErrors(e, _scaffoldKey);
    }
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

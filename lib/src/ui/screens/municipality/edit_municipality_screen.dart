import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/screens/add_municipality/add_municipality_festive_screen.dart';
import 'package:app/src/ui/screens/add_municipality/add_municipality_info_screen.dart';
import 'package:app/src/ui/screens/add_municipality/add_municipality_presentation_screen.dart';
import 'package:app/src/ui/screens/add_municipality/add_municipality_report_screen.dart';
import 'package:app/src/ui/screens/add_municipality/add_municipality_sites_screen.dart';
import 'package:app/src/ui/screens/add_municipality/add_municipality_visits_screen.dart';

import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditMunicipalityScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle:true,),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(
            AppLocalizations.of(context).translate("editMunicipality"),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          title: Text(AppLocalizations.of(context).translate("municipality")),
          onTap: () {
            navigateTo(context, AddMunicipalityInfoScreen(municipality: Provider.of<UserNotifier>(context, listen: false).appUser.municipality,));
          },
          trailing: Icon(Icons.keyboard_arrow_right),
        ),
        ListTile(
          title: Text(AppLocalizations.of(context)
              .translate("municipalityPresentation")),
          onTap: () {
            navigateTo(context, AddMunicipalityPresentationScreen());
          },
          trailing: Icon(Icons.keyboard_arrow_right),
        ),
        ListTile(
          title: Text(AppLocalizations.of(context).translate("graphicReport")),
          onTap: () {
            navigateTo(context, AddMunicipalityReport());
          },
          trailing: Icon(Icons.keyboard_arrow_right),
        ),
        ListTile(
          title:
              Text(AppLocalizations.of(context).translate("recommendedVisits")),
          onTap: () {
            navigateTo(context, AddMunicipalityVisitsScreen());
          },
          trailing: Icon(Icons.keyboard_arrow_right),
        ),
        ListTile(
          title: Text(AppLocalizations.of(context).translate("eatSleepOthers")),
          onTap: () {
            navigateTo(context, AddMunicipalitySitesScreen());
          },
          trailing: Icon(Icons.keyboard_arrow_right),
        ),
        ListTile(
          title: Text(AppLocalizations.of(context).translate("festive")),
          onTap: () {
            navigateTo(context, AddMunicipalityFestiveScreen());
          },
          trailing: Icon(Icons.keyboard_arrow_right),
        ),
      ],
    );
  }
}

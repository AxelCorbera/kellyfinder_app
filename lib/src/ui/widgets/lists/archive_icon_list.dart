import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/globals.dart' as globals;
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/model/archive/archive_icon.dart';
import 'package:app/src/model/municipality/municipality.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/icons/custom_icons.dart';
import 'package:app/src/ui/screens/add_archive/archive_selection_screen.dart';
import 'package:app/src/ui/screens/add_municipality/add_municipality_info_screen.dart';
import 'package:app/src/ui/screens/add_municipality/add_municipality_screen.dart';
import 'package:app/src/ui/screens/municipality/edit_municipality_screen.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:app/src/config/string_casing_extension.dart';

final List<ArchiveIcon> _archives = [
  ArchiveIcon("Oferta", CustomIcons.oferta, Offer),
  ArchiveIcon("Demanda", CustomIcons.demanda, Demand),
  ArchiveIcon("Publicar empresa", CustomIcons.empresa, Company),
  ArchiveIcon("Publicar municipio", Icons.business, Municipality),
];

class ArchiveIconList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: _archives.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          contentPadding: const EdgeInsets.all(16),
          title: Text(
          _getText(_archives[index].type, context),
            style: Theme.of(context).textTheme.subtitle1,
          ),
          leading: Icon(
            _archives[index].icon,
            size: 48,
            color: Theme.of(context).primaryColor,
          ),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            globals.archiveType = _archives[index].type;

            _performNavigation(_archives[index].type, context);
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
    );
  }

  void _performNavigation(dynamic type, BuildContext context) {
    if (type == Municipality) {
      Municipality municipality =
          Provider.of<UserNotifier>(context, listen: false)
              .appUser
              .municipality;

      if (municipality != null)
        navigateTo(context, EditMunicipalityScreen());
      else
        navigateTo(context, AddMunicipalityScreen());
    } else
      navigateTo(context, ArchiveSelectionScreen());
  }

  String _getText(dynamic type, BuildContext context) {
    if (type == Offer)
      return AppLocalizations.of(context).translate("searchEmployee");
    else if (type == Demand)
      return AppLocalizations.of(context).translate("searchJob");
    else if (type == Company)
      return AppLocalizations.of(context).translate("publishCompany");
    else if (type == Municipality)
      return AppLocalizations.of(context).translate("publishMunicipality");

    return "";
  }
}

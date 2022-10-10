import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/globals.dart' as globals;
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/widgets/items/archive/archive_match_card.dart';
import 'package:app/src/utils/constants/searching_type.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ArchiveSelectCard extends StatefulWidget {
  @override
  _ArchiveSelectCardState createState() => _ArchiveSelectCardState();
}

class _ArchiveSelectCardState extends State<ArchiveSelectCard> {
  @override
  Widget build(BuildContext context) {
    List<Archive> archives;
    if (globals.searchingType == SearchingType.OFFER)
      archives =
          Provider.of<UserNotifier>(context, listen: false).appUser.demands;
    else if (globals.searchingType == SearchingType.DEMAND)
      archives =
          Provider.of<UserNotifier>(context, listen: false).appUser.offers;
    else
      archives = [];

    return Scaffold(
      appBar: AppBar(centerTitle:true,
        title: Text(_getTitle()),
      ),
      body: ListView.builder(
        itemCount: archives.length,
        itemBuilder: (BuildContext context, int index) {
          return ArchiveMatchCard(archive: archives[index]);
        },
      ),
    );
  }

  _getTitle() {
    if (globals.searchingType == SearchingType.OFFER) {
      return AppLocalizations.of(context).translate("yourDemands");
    } else if (globals.searchingType == SearchingType.DEMAND) {
      return AppLocalizations.of(context).translate("yourOffers");
    } else {
      return AppLocalizations.of(context).translate("yourArchives");
    }
  }
}

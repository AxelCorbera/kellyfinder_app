import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/globals.dart' as globals;
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/screens/add_archive/archive_category_screen.dart';
import 'package:app/src/ui/widgets/dialog/custom_dialog.dart';
import 'package:app/src/ui/widgets/items/archive/archive_selection/archive_selection_company.dart';
import 'package:app/src/ui/widgets/items/archive/archive_selection/archive_selection_offer.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ArchiveSelectionScreen extends StatefulWidget {
  @override
  _ArchiveSelectState createState() => _ArchiveSelectState();
}

class _ArchiveSelectState extends State<ArchiveSelectionScreen> {

  @override
  void initState() {
    Future.delayed(Duration.zero, (){
      if (globals.archiveType == Offer) {
        if(Provider.of<UserNotifier>(context, listen: false)
            .appUser
            .offers.length == 0){
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomDialog(
                title: AppLocalizations.of(context).translate("offer_popup_text"),
                hasCancel: false,
              );
            },
          );
        }
      }

      if (globals.archiveType == Demand) {
        if(Provider.of<UserNotifier>(context, listen: false)
            .appUser
            .offers.length == 0){
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomDialog(
                title: AppLocalizations.of(context).translate("demand_popup_text"),
                hasCancel: false,
              );
            },
          );
        }
      }

      if (globals.archiveType == Company) {
        if(Provider.of<UserNotifier>(context, listen: false)
            .appUser
            .offers.length == 0){
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomDialog(
                title: AppLocalizations.of(context).translate("company_popup_text"),
                hasCancel: false,
              );
            },
          );
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle:true,
        title: Text(_getTitle()),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              String limitErrorString = "";

              List<Archive> archives = [];

              if (globals.archiveType == Offer) {
                archives = Provider.of<UserNotifier>(context, listen: false)
                    .appUser
                    .offers;
                limitErrorString = AppLocalizations.of(context)
                    .translate("archive_limit_offer");
              } else if (globals.archiveType == Demand) {
                archives = Provider.of<UserNotifier>(context, listen: false)
                    .appUser
                    .demands;
                limitErrorString = AppLocalizations.of(context)
                    .translate("archive_limit_demand");
              } else if (globals.archiveType == Company) {
                archives = Provider.of<UserNotifier>(context, listen: false)
                    .appUser
                    .companies;
                limitErrorString = AppLocalizations.of(context)
                    .translate("archive_limit_company");
              }

              if (archives.length < 2) {
                navigateTo(context, ArchiveCategoryScreen());
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomDialog(
                      title: limitErrorString,
                      hasCancel: false,
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<UserNotifier>(
        builder: (BuildContext context, UserNotifier value, Widget child) {
          List<Archive> archives = [];

          if (globals.archiveType == Offer) {
            archives = value.appUser.offers;
          } else if (globals.archiveType == Demand) {
            archives = value.appUser.demands;
          } else if (globals.archiveType == Company) {
            archives = value.appUser.companies;
          }

          return archives.length == 0
              ? Container(
                  child: Center(
                      child: Text(
                    AppLocalizations.of(context)
                        .translate("no_archives_to_show"),
                    textAlign: TextAlign.center,
                  )),
                )
              : ListView.builder(
                  itemCount: archives.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (globals.archiveType == Offer) {
                      return ArchiveSelectionOffer(archive: archives[index]);
                    } else if (globals.archiveType == Demand) {
                      return ArchiveSelectionOffer(archive: archives[index]);
                    } else if (globals.archiveType == Company) {
                      return ArchiveSelectionCompany(company: archives[index]);
                    }
                    return Container();
                  },
                );
        },
      ),
    );
  }

  _getTitle() {
    if (globals.archiveType == Offer) {
      return AppLocalizations.of(context).translate("yourOffers");
    } else if (globals.archiveType == Demand) {
      return AppLocalizations.of(context).translate("yourDemands");
    } else if (globals.archiveType == Company) {
      return AppLocalizations.of(context).translate("yourCompanies");
    } else {
      return AppLocalizations.of(context).translate("yourArchives");
    }
  }
}

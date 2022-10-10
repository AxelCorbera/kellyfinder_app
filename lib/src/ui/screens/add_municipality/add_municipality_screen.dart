import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/municipality/autonomous_community.dart';
import 'package:app/src/model/municipality/municipality.dart';
import 'package:app/src/model/municipality/province.dart';
import 'package:app/src/ui/screens/add_municipality/add_municipality_info_screen.dart';
import 'package:app/src/ui/screens/municipality_list/autonomous_community_list_screen.dart';
import 'package:app/src/ui/screens/municipality_list/municipality_list_screen.dart';
import 'package:app/src/ui/screens/municipality_list/province_list_screen.dart';
import 'package:app/src/ui/widgets/button/custom_button.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:app/src/config/string_casing_extension.dart';

class AddMunicipalityScreen extends StatefulWidget {
  @override
  _AddMunicipalityScreenState createState() => _AddMunicipalityScreenState();
}

class _AddMunicipalityScreenState extends State<AddMunicipalityScreen> {
  AutonomousCommunity community;
  Province province;
  Municipality municipality;

  bool communityError = false;
  bool provinceError = false;
  bool municipalityError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate("publishMunicipality"),
        ),
      ),
      body: _buildBody(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CustomButton(
        text: AppLocalizations.of(context).translate("next"),
        function: () {
          communityError = community == null ? true : false;
          provinceError = province == null ? true : false;
          municipalityError = municipality == null ? true : false;

          if (!communityError && !municipalityError && !provinceError) {
            navigateTo(
              context,
              AddMunicipalityInfoScreen(municipality: municipality, isCreating: true,),
            );
          } else {
            setState(() {});
          }
        },
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              AppLocalizations.of(context).translate("autonomousCommunity"),
              style: Theme.of(context).textTheme.subtitle1,
            ),
            subtitle: Text(
              community?.name ??
                  AppLocalizations.of(context).translate("addCommunity"),
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                    color: getColor(community == null, communityError),
                  ),
            ),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () async {
              final result = await navigateTo(
                context,
                AutonomousCommunityListScreen(),
                isWaiting: true,
              );

              if (result != null) {
                setState(() {
                  community = result;
                  province = null;
                  municipality = null;
                });
              }
            },
          ),
          if (community != null)
            ListTile(
              title: Text(
                AppLocalizations.of(context).translate("province"),
                style: Theme.of(context).textTheme.subtitle1,
              ),
              subtitle: Text(
                province?.name ??
                    AppLocalizations.of(context).translate("addProvince"),
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: getColor(province == null, provinceError),
                    ),
              ),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () async {
                final result = await navigateTo(
                  context,
                  ProvinceListScreen(community: community),
                  isWaiting: true,
                );

                if (result != null) {
                  setState(() {
                    province = result;
                    //community = null;
                    municipality = null;
                  });
                }
              },
            ),
          if (province != null)
            ListTile(
              title: Text(
                AppLocalizations.of(context).translate("municipality"),
                style: Theme.of(context).textTheme.subtitle1,
              ),
              subtitle: Text(
                municipality?.name ??
                    AppLocalizations.of(context).translate("addMunicipality"),
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: getColor(municipality == null, municipalityError),
                    ),
              ),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () async {
                municipality = await navigateTo(
                  context,
                  MunicipalityListScreen(province: province, isCreating: true,),
                  isWaiting: true,
                );

                setState(() {});
              },
            ),
        ],
      ),
    );
  }

  Color getColor(bool isNull, bool error) {
    if (isNull) {
      if (error) return Colors.red;
    }

    return Theme.of(context).primaryColor;
  }
}

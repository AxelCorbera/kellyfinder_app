import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/ui/screens/municipality_details/municipality_info_text.dart';
import 'package:flutter/material.dart';

class MunicipalityEmptyDetailsScreen extends StatefulWidget {
  @override
  _MunicipalityEmptyDetailsScreenState createState() =>
      _MunicipalityEmptyDetailsScreenState();
}

class _MunicipalityEmptyDetailsScreenState
    extends State<MunicipalityEmptyDetailsScreen> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 0), () async {
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                AppLocalizations.of(context)
                    .translate("notRegisteredMunicipality"),
              ),
              actions: <Widget>[
                SimpleDialogOption(
                  child: Text(
                    AppLocalizations.of(context)
                        .translate("accept")
                        .toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });

      Navigator.pop(context);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate("municipality"),
        ),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: _buildBody(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      color: Theme.of(context).primaryColorLight.withOpacity(0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MunicipalityInfoText(
            title: AppLocalizations.of(context).translate("mayor"),
            subtitle: "",
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: MunicipalityInfoText(
                  title: AppLocalizations.of(context).translate("population"),
                  subtitle: "",
                ),
              ),
              Expanded(
                child: MunicipalityInfoText(
                  title: AppLocalizations.of(context).translate("elevation"),
                  subtitle: "",
                ),
              ),
            ],
          ),
          MunicipalityInfoText(
            title: AppLocalizations.of(context).translate("location"),
            subtitle: "",
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: MunicipalityInfoText(
                  title: AppLocalizations.of(context).translate("politicParty"),
                  subtitle: "",
                ),
              ),
              Expanded(
                child: MunicipalityInfoText(
                  title: AppLocalizations.of(context).translate("phone"),
                  subtitle: "",
                ),
              ),
            ],
          ),

          ListTile(
            dense: true,
            title: Text(
              AppLocalizations.of(context)
                  .translate("municipalityPresentation"),
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          //MunicipalityVideo(),
          SizedBox(height: 8),
          ListTile(
            dense: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context).translate("graphicReport"),
                  style: Theme.of(context).textTheme.subtitle1.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                /*FlatButton(
                  padding: EdgeInsets.all(0),
                  onPressed: () {
                    navigateTo(context, MunicipalityImagesScreen());
                  },
                  child: Text(
                    "Ver mas",
                    style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: AppStyles.lightGreyColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )*/
              ],
            ),
          ),
          /*Container(
            height: 96,
            child: ListView.separated(
              itemCount: 5,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    navigateTo(context, MunicipalityImagesScreen(index: index));
                  },
                  child: Container(
                    height: 96,
                    width: 96,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      child: Image.network(
                        "https://www.blogdelfotografo.com/wp-content/uploads/2020/04/fotografo-paisajes.jpg",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(width: 8);
              },
            ),
          ),*/
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Text(
              AppLocalizations.of(context).translate("interestSites"),
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          /*ListView.separated(
            itemCount: 3,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                dense: true,
                onTap: () {},
                title: Text(
                  "Museo de Almería",
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      .copyWith(fontWeight: FontWeight.w500),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.location_on),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "Carretera de Ronda, 91",
                          style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: AppStyles.lightGreyColor),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return Divider(height: 1);
            },
          ),*/
          SizedBox(height: 16),
          //MunicipalitySites(),
          ListTile(
            dense: true,
            title: Text(
              AppLocalizations.of(context).translate("festive"),
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          /*ListView.separated(
            itemCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                dense: true,
                title: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "12/09/2020",
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                        color: AppStyles.lightGreyColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Dia grande de las hogueras",
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          launchWeb("www.google.com");
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "Saber más",
                            style:
                            Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Theme.of(context).primaryColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return Divider(height: 1);
            },
          ),*/
          SizedBox(height: 16)
        ],
      ),
    );
  }
}

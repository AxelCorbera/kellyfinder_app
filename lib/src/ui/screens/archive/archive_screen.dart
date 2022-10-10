import 'dart:developer';

import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/globals.dart' as globals;
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/model/category.dart';
import 'package:app/src/model/user.dart';
import 'package:app/src/provider/category_notifier.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/screens/add_archive/archive_offer_screen.dart';
import 'package:app/src/ui/screens/archive/archive_list_screen.dart';
import 'package:app/src/ui/screens/company/company_list_screen.dart';
import 'package:app/src/ui/widgets/dialog/custom_dialog.dart';
import 'package:app/src/ui/widgets/icon/home_icon.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/ui/widgets/lists/archive_image_list.dart';
import 'package:app/src/ui/widgets/lists/archive_list.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/constants/searching_type.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class ArchiveScreen extends StatefulWidget {
  @override
  _ArchiveScreenState createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future _futureWait;
  Future _futureLocation;

  List<Archive> _geoArchives;
  List<Archive> _highlightArchives;
  List<Archive> _archives;

  int i = 0;

  geo.Position _position;

  @override
  void initState() {
    super.initState();

    _futureLocation = _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Category subcategory = Provider.of<CategoryNotifier>(context, listen: false)
            .selectedSubcategory;

        Provider.of<CategoryNotifier>(context, listen: false).selectSubcategory(subcategory.parentCategory);

        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(centerTitle:true,
          title: Text(
            globals.searchingType == SearchingType.DEMAND
                ? AppLocalizations.of(context).translate("demand")
                : AppLocalizations.of(context).translate("offer"),
          ),
          actions: <Widget>[
            HomeIcon(),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: _buildContent(context),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    Category subcategory = Provider.of<CategoryNotifier>(context, listen: false)
        .selectedSubcategory;

    return Column(
      children: <Widget>[
        if (subcategory.findSectorPic != null)
          InkWell(
            onTap: () {
              // Si es una categoría de Compartidos, no mostrar CompanyListScreen
              if (subcategory.parentCategory.type != "shared" &&
                  subcategory.parentCategory.type != "search" &&
                  subcategory.parentCategory.type != "have")
                navigateTo(context, CompanyListScreen());
            },
            child: Image.network(
              subcategory.findSectorPic,
              fit: BoxFit.fitHeight,
              width: MediaQuery.of(context).size.width,
            ),
          ),
        if (subcategory.findSectorPic == null)
          Material(
            elevation: 4.0,
            color: Theme.of(context).disabledColor,
            clipBehavior: Clip.hardEdge,
            child: Ink.image(
              image: AssetImage("assets/business.png"),
              fit: BoxFit.fitHeight,
              width: MediaQuery.of(context).size.width,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.srcOver,
              ),
              height: 120,
              child: InkWell(
                onTap: () {
                  if (subcategory.parentCategory.type != "shared")
                    navigateTo(context, CompanyListScreen());
                },
                child: Center(
                  child: Text(
                    AppLocalizations.of(context).translate("sectorBusiness"),
                    style: Theme.of(context).textTheme.subtitle1.copyWith(
                          color: Theme.of(context).accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
            ),
          ),
        // Si es una categoría de COMPARTIDOS, mostrar botón para crear ficha
        if (subcategory.parentCategory.type == "shared" ||
            subcategory.parentCategory.type == "search" ||
            subcategory.parentCategory.type == "have")
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: FloatingActionButton.extended(
              heroTag: null,
              backgroundColor: Theme.of(context).accentColor,
              onPressed: () async {
                navigateTo(context, ArchiveOfferScreen());
                /*final result = await navigateTo(
                context,
                ArchiveCompanyScreen(fromList: true),
                isWaiting: true,
              );

              if (result is Company) {
                setState(() {
                  _archives.add(result);
                });
              }*/
              },
              label: Text(
                _getButtonText(subcategory.parentCategory.type),
                /*AppLocalizations.of(context)
                    .translate("publishShared")
                    .toUpperCase(),*/
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        _buildLists(context),
      ],
    );
  }

  Widget _buildLists(BuildContext context) {
    Category category =
        Provider.of<CategoryNotifier>(context, listen: false).selectedCategory;
    Category subcategory = Provider.of<CategoryNotifier>(context, listen: false)
        .selectedSubcategory;

    return FutureBuilder(
      future: _futureLocation,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return FutureBuilder(
            future: _futureWait,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  if (i == 0) {
                    i++;

                    _checkLists();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (category.isDifferent) ...[
                        if (category.type != "social" ||
                            subcategory.type == "intern")
                          if (globals.searchingType == SearchingType.DEMAND)
                            _buildGeoList(context),
                        _buildHighlightList(context),
                      ],
                      ConstrainedBox(
                        constraints: BoxConstraints(minHeight: 140),
                        child: ArchiveList(archives: _archives),
                      ),
                    ],
                  );
                }
              }
              return Container(
                height: 100,
                child: FutureCircularIndicator(),
              );
            },
          );
        }
        return Container(
          height: 100,
          child: FutureCircularIndicator(),
        );
      },
    );
  }

  Widget _buildGeoList(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          dense: true,
          title: Text(
            AppLocalizations.of(context).translate("geoAvailability"),
            style: Theme.of(context).textTheme.subtitle1,
          ),
          trailing: InkWell(
            onTap: () {
              if (_geoArchives.isNotEmpty)
                navigateTo(
                  context,
                  ArchiveListScreen(
                    archives: _geoArchives,
                    title: AppLocalizations.of(context)
                        .translate("geoAvailability"),
                  ),
                );
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Text(
                AppLocalizations.of(context).translate("seeAll"),
                style: Theme.of(context).textTheme.caption,
              ),
            ),
          ),
        ),
        Container(
          height: 52,
          child: ArchiveImageList(archives: _geoArchives),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          height: 1,
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).disabledColor,
        ),
      ],
    );
  }

  Widget _buildHighlightList(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          dense: true,
          title: Text(
            AppLocalizations.of(context).translate("highlight"),
            style: Theme.of(context).textTheme.subtitle1,
          ),
          trailing: InkWell(
            onTap: () {
              if (_highlightArchives.isNotEmpty)
                navigateTo(
                    context,
                    ArchiveListScreen(
                      archives: _highlightArchives,
                      title:
                          AppLocalizations.of(context).translate("highlight"),
                    ));
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Text(
                AppLocalizations.of(context).translate("seeAll"),
                style: Theme.of(context).textTheme.caption,
              ),
            ),
          ),
        ),
        Container(
          height: 52,
          child: ArchiveImageList(archives: _highlightArchives),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          height: 1,
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).disabledColor,
        ),
      ],
    );
  }

  Future getByParams({bool highlight = false, bool geo = false}) async {
    try {
      Map params = {
        "type":
            globals.searchingType == SearchingType.DEMAND ? "demand" : "offer",
        "category_id": Provider.of<CategoryNotifier>(context, listen: false)
            .selectedSubcategory
            .id,
      };

      Map params2 = {
        "type":
        globals.searchingType == SearchingType.DEMAND ? "demand" : "offer",
        "category_id": Provider.of<CategoryNotifier>(context, listen: false)
            .selectedSubcategory
            .id,
      };

      if (globals.searchingType == SearchingType.DEMAND && geo)
        params.putIfAbsent("has_geographic_availability", () => geo);

      if (highlight) params.putIfAbsent("is_highlight", () => highlight);

      if (_position != null) {
        params.putIfAbsent("lat", () => _position.latitude);
        params.putIfAbsent("lng", () => _position.longitude);
      }

      log(params2.toString());

      final test = await ApiProvider().test(params2);

      log(params2.toString());

      List<Archive> archives = await ApiProvider().performGetByParams(params);

      if (geo) {
        _geoArchives = archives;
      } else if (highlight) {
        _highlightArchives = archives;
      } else {
        _archives = archives;
      }

      return true;
    } catch (e) {
      print(e);
    }
  }

  void _checkLists() {
    Category category =
        Provider.of<CategoryNotifier>(context, listen: false).selectedCategory;

    Category subcategory = Provider.of<CategoryNotifier>(context, listen: false)
        .selectedSubcategory;

    AppUser appUser = Provider.of<UserNotifier>(context, listen: false).appUser;

    if (category.isDifferent) {
      if (category.type == "social" && subcategory.type != "intern") {
        if (_archives != null && _archives.isEmpty && _highlightArchives != null && _highlightArchives.isEmpty) {
          if (globals.searchingType == SearchingType.DEMAND) {
            if (appUser.demands == null) {
              _showDialog();
            }
          } else {
            if (appUser.offers == null) {
              _showDialog();
            }
          }
        }
      } else {
        if (globals.searchingType == SearchingType.DEMAND) {
          if (_archives != null && _archives.isEmpty &&
              _highlightArchives.isEmpty &&
              _geoArchives.isEmpty) {
            if (appUser.demands == null) {
              _showDialog();
            }
          }
        } else {
          if (_archives != null && _archives.isEmpty && _highlightArchives != null
              && _highlightArchives.isEmpty) {
            if (appUser.offers == null) {
              _showDialog();
            }
          }
        }
      }
    } else {
      if (_archives != null && _archives.isEmpty) {
        if (globals.searchingType == SearchingType.DEMAND) {
          if (appUser.demands == null) {
            _showDialog();
          }
        } else {
          if (appUser.offers == null) {
            _showDialog();
          }
        }
      }
    }
  }

  void _showDialog() {
    Future.delayed(
      Duration(seconds: 0),
      () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialog(
              title: AppLocalizations.of(context).translate("addResults"),
              hasCancel: false,
            );
          },
        );
      },
    );
  }

  Future _getLocation() async {
    await _getCurrentLocation();

    _getData();

    return true;
  }

  Future _getCurrentLocation() async {
    try {
      Location location = new Location();

      bool _serviceEnabled = await location.serviceEnabled();

      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
      }

      if (_serviceEnabled) {
        _position = await geo.Geolocator.getCurrentPosition(
            desiredAccuracy: geo.LocationAccuracy.high);
      }

      return true;
    } catch (e) {
      print(e);
      return true;
    }
  }

  Future _getData() async {
    try {
      Future futureArchives = getByParams();

      Category category = Provider.of<CategoryNotifier>(context, listen: false)
          .selectedCategory;

      Category subcategory =
          Provider.of<CategoryNotifier>(context, listen: false)
              .selectedSubcategory;

      if (category.isDifferent) {
        Future futureHighlight = getByParams(highlight: true);

        if (category.type == "social" && subcategory.type != "intern") {
          _futureWait = Future.wait([futureHighlight, futureArchives]);
        } else {
          if (globals.searchingType == SearchingType.DEMAND) {
            Future futureGeo = getByParams(geo: true);

            _futureWait =
                Future.wait([futureHighlight, futureGeo, futureArchives]);
          } else {
            _futureWait = Future.wait([futureHighlight, futureArchives]);
          }
        }
      } else {
        _futureWait = Future.wait([futureArchives]);
      }
    } catch (e) {
      catchErrors(e, _scaffoldKey);
    }
  }

  String _getButtonText(type) {
    if(type == "shared"){
      return AppLocalizations.of(context)
          .translate("publishShared")
          .toUpperCase();
    }else if(type == "search"){
      return AppLocalizations.of(context)
          .translate("publishSearch")
          .toUpperCase();
    }else{
      return AppLocalizations.of(context)
          .translate("publishHave")
          .toUpperCase();
    }

  }
}

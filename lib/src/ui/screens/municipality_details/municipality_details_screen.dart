import 'dart:developer';

import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/app_styles.dart';
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/model/event.dart';
import 'package:app/src/model/municipality/image.dart';
import 'package:app/src/model/municipality/municipality.dart';
import 'package:app/src/model/municipality/recommended_visit.dart';
import 'package:app/src/model/municipality/service.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/screens/municipality/route_municipality_company_list.dart';
import 'package:app/src/ui/screens/municipality_details/municipality_images_screen.dart';
import 'package:app/src/ui/screens/municipality_details/municipality_info_text.dart';
import 'package:app/src/ui/screens/municipality_details/municipality_sites.dart';
import 'package:app/src/ui/screens/municipality_details/municipality_video.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/api/api_google_autocomplete.dart';
import 'package:app/src/utils/methods/conversions.dart';
import 'package:app/src/utils/methods/launch_location.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app/src/config/string_casing_extension.dart';

class MunicipalityDetailsScreen extends StatefulWidget {
  final Municipality municipality;

  MunicipalityDetailsScreen({this.municipality});

  @override
  _MunicipalityDetailsScreenState createState() =>
      _MunicipalityDetailsScreenState();
}

class _MunicipalityDetailsScreenState extends State<MunicipalityDetailsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future _futurePics;
  Future _futureVisits;
  Future _futureCategories;
  Future _futureEvents;

  List<MunicipalityImage> images = [];
  List<RecommendedVisit> _visits = [];
  List<Service> _services = [];
  List<Event> _events;

  geo.Position _position;

  @override
  void initState() {
    _futurePics = getPics();
    _futureVisits = getVisits();
    _futureCategories = getCategories();
    _futureCategories = getCompanies();
    _futureEvents = getEvents();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bgMunicipalityDetails,
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate("municipality"),
        ),
        backgroundColor: AppStyles.bgMunicipalityDetailsAppBar,
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
      //color: Theme.of(context).primaryColorLight.withOpacity(0.15),
      color: AppStyles.bgMunicipalityDetails,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!widget.municipality.isAttached) _buildBasicInfo(),
          if (widget.municipality.isAttached) _buildMunicipalityDescription(),
          if (!widget.municipality.isAttached)
            ListTile(
              dense: true,
              title: Text(
                AppLocalizations.of(context)
                    .translate("municipalityPresentation"),
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      //color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          if (widget.municipality?.video != null)
            MunicipalityVideo(
              municipality: widget.municipality,
            ),
          if (widget.municipality?.video == null &&
              !widget.municipality.isAttached)
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    AppLocalizations.of(context)
                        .translate("municipality_no_video"),
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(color: AppStyles.lightGreyColor),
                  ),
                ),
                SizedBox(height: 8),
              ],
            ),
          ListTile(
            dense: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context).translate("graphicReport"),
                  style: Theme.of(context).textTheme.subtitle1.copyWith(
                        //color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                FutureBuilder(
                    future: _futurePics,
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          if (images.length > 0)
                            return FlatButton(
                              padding: EdgeInsets.all(0),
                              onPressed: () {
                                navigateTo(
                                    context,
                                    MunicipalityImagesScreen(
                                      images: images,
                                    ));
                              },
                              child: Text(
                                AppLocalizations.of(context)
                                    .translate("seeMore"),
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    .copyWith(
                                      color: AppStyles.lightGreyColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            );
                        }
                      }
                      return SizedBox(
                        height: 0,
                      );
                    }),
              ],
            ),
          ),
          FutureBuilder(
              future: _futurePics,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {}
                }
                return SizedBox(
                  height: 0,
                );
              }),
          FutureBuilder(
              future: _futurePics,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    if (images.length == 0) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          AppLocalizations.of(context)
                              .translate("municipality_no_report"),
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(color: AppStyles.lightGreyColor),
                        ),
                      );
                    }

                    return Container(
                      height: 96,
                      child: ListView.separated(
                        itemCount: images.length,
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              navigateTo(
                                  context,
                                  MunicipalityImagesScreen(
                                    index: index,
                                    images: images,
                                  ));
                            },
                            child: Container(
                              height: 96,
                              width: 96,
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                child: Image.network(
                                  images[index].pic,
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
                    );
                  }
                }

                return FutureCircularIndicator();
              }),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Text(
              AppLocalizations.of(context).translate("interestSites"),
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                    //color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          FutureBuilder(
              future: _futureVisits,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    if (_visits.length == 0)
                      return Padding(
                        padding: EdgeInsets.only(left: 16, right: 16, top: 8),
                        child: Text(
                          AppLocalizations.of(context)
                              .translate("municipality_no_visits"),
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(color: AppStyles.lightGreyColor),
                        ),
                      );
                    return ListView.separated(
                      itemCount: _visits.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          dense: true,
                          onTap: () {
                            if (_visits[index].lat != null &&
                                _visits[index].lng != null) {
                              MapDirectionsApi().openMap(
                                  _visits[index].lat, _visits[index].lng);
                            }
                          },
                          title: Text(
                          _visits[index].name,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500),
                          ),
                          subtitle: Opacity(
                            opacity: _visits[index].lat == null ? 0.6 : 1,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.location_on,
                                    color:
                                        AppStyles.bgMunicipalityDetailsAppBar,
                                  ),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _visits[index].lat == null
                                          ? AppLocalizations.of(context).translate(
                                              "municipality_detail_visit_no_location")
                                          : _visits[index].address,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(
                                              color: AppStyles
                                                  .lightGreyColor /*AppStyles.lightGreyColor*/,
                                              fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider(height: 1);
                      },
                    );
                  }
                }

                return FutureCircularIndicator();
              }),
          SizedBox(height: 16),
          _services.isNotEmpty?
              Column(
                children: _buildServiceItems(),
              ):
          FutureCircularIndicator(),
          // FutureBuilder(
          //   future: _futureCategories,
          //     builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          //   if (snapshot.connectionState == ConnectionState.done) {
          //     if (snapshot.hasData) {
          //       return Column(
          //         children: _buildServiceItems(),
          //       );
          //     }
          //   }
          //   return FutureCircularIndicator();
          // }),
          ListTile(
            dense: true,
            title: Text(
              AppLocalizations.of(context).translate("festive"),
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                    //color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          FutureBuilder(
              future: _futureEvents,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    if (_events.length == 0)
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          AppLocalizations.of(context)
                              .translate("municipality_no_events"),
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(color: AppStyles.lightGreyColor),
                        ),
                      );
                    return ListView.separated(
                      itemCount: _events.length,
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
                                formatStringDate(_events[index].date),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(
                                      color: AppStyles.lightGreyColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              Expanded(
                                child: Text(
                              _events[index].name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                          subtitle: _events[index].link != ""
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      /*Icon(Icons.language),
                                SizedBox(width: 4.0,),*/
                                      GestureDetector(
                                        onTap: () {
                                          launchWeb(_events[index].link);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text(
                                            AppLocalizations.of(context)
                                                .translate("knowMore"),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .copyWith(
                                                  //color: Theme.of(context).primaryColor,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider(height: 1);
                      },
                    );
                  }
                }

                return FutureCircularIndicator();
              }),
          SizedBox(height: 16)
        ],
      ),
    );
  }

  Future getPics() async {
    try {
      images =
          await ApiProvider().getMunicipalityPics({}, widget.municipality.id);

      return true;
    } catch (e) {
      catchErrors(e, _scaffoldKey);
    }
  }

  Future getVisits() async {
    try {
      _visits =
          await ApiProvider().getRecommendedVisits({}, widget.municipality.id);

      return true;
    } catch (e) {
      catchErrors(e, _scaffoldKey);
    }
  }

  Future getCategories() async {
    try {
      _services = await ApiProvider().getMunicipalityServices({});
      await getCompanies();
      setState(() {
      });
      return true;
    } catch (e) {
      catchErrors(e, _scaffoldKey);
    }
  }

  List<Widget> _buildServiceItems() {
    return _services.map<Widget>((service) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
            service.name,
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                    //color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Container(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: service.categories.length,
              padding: EdgeInsets.all(16),
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    navigateTo(
                        context,
                        MunicipalityCompanyList(
                          municipality: widget.municipality,
                          serviceCategory: service.categories[index],
                        ));
                    //widget.callback(service.categories[index]);
                    //Navigator.pop(context);
                  },
                  child: service.categories[index].companyNumber == 0
                      ? Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            //color: Theme.of(context).primaryColorLight.withOpacity(0.4),
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          child: Image.network(service.categories[index].image),
                        )
                      : Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                //color: Theme.of(context).primaryColorLight.withOpacity(0.4),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                              ),
                              child: Image.network(service.categories[index].image),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: LinearGradient(
                                      colors: [
                                        Colors.blue,
                                        Colors.lightBlueAccent
                                      ],
                                    begin: Alignment.bottomLeft,
                                    end: Alignment.topRight
                                  )
                                ),
                              )
                            ),
                          ],
                        ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(width: 8);
              },
            ),
          ),
        ],
      );
    }).toList();
  }

  Future getEvents() async {
    try {
      _events = await ApiProvider().getEvents({}, widget.municipality.id);

      return true;
    } catch (e) {
      catchErrors(e, _scaffoldKey);
    }
  }

  _buildBasicInfo() {
    return Column(
      children: [
        MunicipalityInfoText(
          title: AppLocalizations.of(context).translate("mayor"),
          subtitle: widget.municipality?.major ?? "",
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: MunicipalityInfoText(
                title: AppLocalizations.of(context).translate("population"),
                subtitle: widget.municipality.isRegistered
                    ? widget.municipality?.population.toString()
                    : "",
              ),
            ),
            Expanded(
              child: MunicipalityInfoText(
                title: AppLocalizations.of(context).translate("elevation"),
                subtitle: widget.municipality.isRegistered
                    ? widget.municipality?.elevation.toString() + "m"
                    : "",
              ),
            ),
          ],
        ),
        MunicipalityInfoText(
          title: AppLocalizations.of(context).translate("location"),
          subtitle: widget.municipality?.directionTownHall ?? "",
          titleIcon: Icons.location_on,
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: MunicipalityInfoText(
                title: AppLocalizations.of(context).translate("politicParty"),
                subtitle: widget.municipality?.politicalParty ?? "",
              ),
            ),
            Expanded(
              child: MunicipalityInfoText(
                title: AppLocalizations.of(context).translate("phone"),
                subtitle: widget.municipality?.phone ?? "",
              ),
            ),
          ],
        ),
      ],
    );
  }

  _buildMunicipalityDescription() {
    return ListTile(
      dense: true,
      title: Text(
        AppLocalizations.of(context).translate("description"),
        style: Theme.of(context).textTheme.subtitle1.copyWith(
              //color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w700,
            ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
            widget.municipality.description != null
                ? widget.municipality.description.toSentenceCase()
                : AppLocalizations.of(context)
                    .translate("municipality_no_description"),
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .copyWith(color: AppStyles.lightGreyColor)),
      ),
    );
  }

  Future<List<Archive>> getByParams(int serviceCategoryId) async {
    if(_position==null)
    await _getCurrentLocation();

    try {
      Map params = {
        "municipality_id": widget.municipality.id,
        "card_advertising_category_id": serviceCategoryId
      };

      if (_position != null) {
        params.putIfAbsent("lat", () => _position.latitude);
        params.putIfAbsent("lng", () => _position.longitude);
      }

      return await ApiProvider().getMunicipalityCompanies(params);
    } catch (e) {
      catchErrors(e, _scaffoldKey);
    }
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

  Future getCompanies() async {
    try {
      for (int i = 0; i < _services.length; i++) {
        for (int j = 0; j < _services[i].categories.length; j++) {
          final companies = await getByParams(_services[i].categories[j].id);
          _services[i].categories[j].companyNumber = companies.length;
          print(_services[i].categories[j].companyNumber);
        }
      }
      setState(() {
      });
    } catch (e) {
      catchErrors(e, _scaffoldKey);
    }
  }
}

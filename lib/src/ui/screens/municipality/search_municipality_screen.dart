import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/app_styles.dart';
import 'package:app/src/config/string_casing_extension.dart';
import 'package:app/src/model/municipality/municipality.dart';
import 'package:app/src/ui/screens/municipality_details/municipality_details_screen.dart';
import 'package:app/src/ui/screens/municipality_details/municipality_empty_details.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/ui/widgets/items/municipality_item.dart';
import 'package:app/src/utils/alerts/alert_dialog_municipality_empty.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:geolocator/geolocator.dart' as geo;

class SearchMunicipalityScreen extends StatefulWidget {
  final bool willPop;
  final bool registeredOnly;
  final bool isSearch;
  final bool fromCommunique;

  const SearchMunicipalityScreen(
      {Key key,
      this.willPop = false,
      this.isSearch = false,
      this.registeredOnly = false,
      this.fromCommunique = false})
      : super(key: key);

  @override
  _SearchMunicipalityScreenState createState() =>
      _SearchMunicipalityScreenState();
}

class _SearchMunicipalityScreenState extends State<SearchMunicipalityScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _searchInputController = TextEditingController();

  Future _futureLocation;
  Future _futureWait;

  geo.Position _position;

  List<Municipality> _municipalities = [];

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  int _currentPage = 0;
  int _pageLimit = 10;

  String query = "";

  @override
  void initState() {
    _futureLocation = _getLocation();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: TextField(
          controller: _searchInputController,
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            setState(() {
              _currentPage = 0;
              query = value;
              _municipalities.clear();
            });

            _futureWait = getMunicipalities();
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(0),
            isDense: true,
            labelText: AppLocalizations.of(context).translate("municipality"),
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SmartRefresher(
      enablePullDown: false,
      enablePullUp: true,
      controller: _refreshController,
      onLoading: _onLoading,
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus mode) {
          Widget body;
          if (mode == LoadStatus.idle || mode == LoadStatus.loading) {
            body = Container(height: 40, child: FutureCircularIndicator());
          } else if (mode == LoadStatus.failed) {
            body = Text("");
          } else if (mode == LoadStatus.canLoading) {
            body = Text(
              AppLocalizations.of(context).translate("lazy_load_loading"),
            );
          } else {
            body = Text(
              AppLocalizations.of(context).translate("lazy_load_no_more"),
            );
          }
          return Container(
            height: 55.0,
            child: Center(child: body),
          );
        },
      ),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 8),
            /*ListTile(
              title: Text(
                AppLocalizations.of(context)
                    .translate("municipalitiesRegistered"),
                style: TextStyle(color: AppStyles.lightGreyColor),
              ),
            ),*/
            FutureBuilder(
              future: _futureLocation,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (!snapshot.data) {
                    // No hay ubicación
                    return Container(
                      margin: EdgeInsets.only(top: 24.0),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)
                              .translate("activate_geolocation_message"),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  } else {
                    return FutureBuilder(
                      future: _futureWait,
                      builder: (BuildContext context,
                          AsyncSnapshot<dynamic> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData) {
                            if (_municipalities.length > 0) {
                              return _buildList();
                            } else {
                              if(_searchInputController.text.trim() == ""){
                                return Container(
                                    padding: EdgeInsets.all(16),
                                    child: Text("No hay ningún municipio registrado por el momento", textAlign: TextAlign.center,)
                                );
                              }
                              return Container(
                                padding: EdgeInsets.all(16),
                                  child: Text(AppLocalizations.of(context).translate("municipality_search_no_results"), textAlign: TextAlign.center,)
                              );
                            }
                          }
                        }
                        return Container(
                          height: 100,
                          child: FutureCircularIndicator(),
                        );
                      },
                    );
                  }
                }

                return Container(
                  height: 100,
                  child: FutureCircularIndicator(),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  ListView _buildList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _municipalities.length,
      padding: EdgeInsets.symmetric(vertical: 16),
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () {
            // Si venim de Comunicats, hem de tancar la pantalla al escollir municipi
            if (widget.isSearch /*widget.willPop*/) {
              Navigator.pop(context, _municipalities[index]);
            } else {
               if (_municipalities[index].isRegistered ||
                   _municipalities[index].isAttached) {
                navigateTo(
                    context,
                    MunicipalityDetailsScreen(
                      municipality: _municipalities[index],
                    ));
               } else {
                 navigateTo(
                     context,
                     MunicipalityDetailsScreen(
                       municipality: _municipalities[index],
                     ));
                 AlertDialogMunicipalityEmpty(context);
                //navigateTo(context, MunicipalityEmptyDetailsScreen());
              }
            }
          },
          child: MunicipalityItem(
            municipality: _municipalities[index],
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
          color: AppStyles.lightGreyColor,
        );
      },
    );
  }

  Future _getCurrentLocation() async {
    try {
      Location location = new Location();

      bool _serviceEnabled = await location.serviceEnabled();

      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();

        // Texto activa la ubicación para ver los municipios cerca de tí.
      }

      if (_serviceEnabled) {
        try {
          _position = await geo.Geolocator.getCurrentPosition(
              desiredAccuracy: geo.LocationAccuracy.high);
        } catch (e) {
          // Texto activa la ubicación para ver los municipios cerca de tí.
          print("error");
        }
      }

      return true;
    } catch (e) {
      print(e);
      return true;
    }
  }

  Future _getLocation() async {
    await _getCurrentLocation();

    if (_position != null) {
      _getData();
      return true;
    } else {
      return false;
    }
  }

  void _getData() async {
    _futureWait = getMunicipalities();
  }

  Future getMunicipalities() async {
    setState(() {
      _currentPage++;
    });

    try {
      Map params = {
        "page": _currentPage,
        "lat": _position.latitude,
        "lng": _position.longitude,
        "name": query.trim(),
        //"is_registered": widget.registeredOnly ? 1 : 0
      };

      if (widget.registeredOnly) {
        params.putIfAbsent("is_registered", () => widget.registeredOnly);
      }

      List<Municipality> _results =
          await ApiProvider().getMunicipalitiesByDistance(params);

      if (_results.isNotEmpty) {
        setState(() {
          _municipalities.addAll(_results);
        });

        if (_results.length < _pageLimit) {
          _refreshController.loadNoData();
        } else {
          _refreshController.loadComplete();
        }
      } else {
        _refreshController.loadNoData();
      }

      return true;
    } catch (e) {
      print("error");
      catchErrors(e, _scaffoldKey);
    }
  }

  void _onLoading() async {
    getMunicipalities();
  }
}

import 'dart:async';
import 'dart:io';

import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/app_styles.dart';
import 'package:app/src/model/municipality/communique.dart';
import 'package:app/src/model/municipality/municipality.dart';
import 'package:app/src/model/user/municipal_info.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/screens/add_communique/add_communique_screen.dart';
import 'package:app/src/ui/screens/communique_list/communique_list_audio.dart';
import 'package:app/src/ui/screens/communique_list/communique_list_image.dart';
import 'package:app/src/ui/screens/communique_list/communique_list_municipalities.dart';
import 'package:app/src/ui/screens/communique_list/communique_list_text.dart';
import 'package:app/src/ui/screens/communique_list/communique_list_video.dart';
import 'package:app/src/ui/screens/municipality_list/municipality_list_screen.dart';
import 'package:app/src/ui/widgets/dialog/custom_dialog.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/methods/general.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share/share.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:app/src/config/string_casing_extension.dart';

class CommuniqueListScreen extends StatefulWidget {
  @override
  _CommuniqueListScreenState createState() => _CommuniqueListScreenState();
}

class _CommuniqueListScreenState extends State<CommuniqueListScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  geo.Position _position;
  geo.Position _positionAux;

  Municipality _municipality;
  MunicipalInfo _currentMunicipalityInfo;
  bool _isMunicipalitySelected = false;

  Future _futureCommuniques;
  Future _futureLocation;

  bool isLoadingCommuniques = false;

  Timer _timer;

  List<Widget> list = [];
  List<dynamic> _listItems = [];
  List<Communique> _communiques = [];

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  int _currentPage = 0;
  int _pageLimit = 15;

  bool _isManual = false;

  bool switchInfo = false;

  // Utilizamos esta variable para ir guardando la fecha de cada comunicado y
  // agruparlos por fecha. Si la fecha del comunicado es diferente de la guardada antes,
  // aparece el separador con la fecha, si no, continuamos mostrando comunicados.
  String date;

  String dateAdded;
  String dateDeleted;

  @override
  void initState() {
    _futureLocation = _getLocation();
    super.initState();
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppStyles.bgCommuniqueList,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppStyles.bgCommuniqueListAppBar,
        title: Text(AppLocalizations.of(context).translate("municipalInfo")),
        actions: <Widget>[
          if (Provider.of<UserNotifier>(context, listen: false)
                  .appUser
                  .municipality !=
              null)
            IconButton(
              icon: Icon(Icons.add_box),
              onPressed: () {
                navigateTo(
                    context,
                    AddCommuniqueScreen(
                      municipality: _municipality,
                      connectedUsers: _currentMunicipalityInfo.connectedUsers,
                      callback: () {
                        _resetList();
                        if(!isLoadingCommuniques){
                          getCommuniques();
                        }
                      },
                    ));
              },
              color: Theme.of(context).primaryColor,
            ),
        ],
      ),
      body: FutureBuilder(
        future: _futureLocation,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (!snapshot.hasData) {
              // No hay ubicación
              return Container(
                margin: EdgeInsets.only(top: 24.0),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)
                        .translate("municipality_info_enable_location"),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            } else {
              return SmartRefresher(
                enablePullDown: false,
                enablePullUp: true,
                controller: _refreshController,
                onLoading: _onLoading,
                footer: CustomFooter(
                  builder: (BuildContext context, LoadStatus mode) {
                    return Container(
                      height: 55.0,
                    );
                  },
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SwitchListTile(
                        title: Text(
                          AppLocalizations.of(context)
                              .translate("getMunicipalInfo"),
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                        onChanged: (bool value) {
                          setState(() {
                            switchInfo = value;
                          });

                          editMunicipalInfo();
                        },
                        //activeColor: Theme.of(context).primaryColor,
                        activeColor: AppStyles.bgCommuniqueListAppBar,
                        value: switchInfo,
                      ),
                      ListTile(
                        onTap: () async {
                          Municipality muni = await navigateTo(
                            context,
                            CommuniqueListMunicipalities(
                              position: _position,
                            ),
                            isWaiting: true,
                          );

                          if (muni != null) {
                            setState(() {
                              _isManual = true;
                            });

                            await editMunicipalInfo(muni: muni);
                          }
                        },
                        title: Text(
                          AppLocalizations.of(context)
                              .translate("changeMunicipality"),
                        ),
                        trailing: Icon(Icons.keyboard_arrow_right),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            if (_municipality != null)
                              Row(
                                children: <Widget>[
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Text(
                                    "${AppLocalizations.of(context).translate("connectedTo")} " +
                                        _municipality?.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(
                                            color:
                                                Theme.of(context).primaryColor),
                                  ),
                                ],
                              ),
                            Row(
                              children: [
                                FlatButton.icon(
                                  icon: Icon(Icons.gps_fixed),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 0.0, horizontal: 0.0),
                                  label: Text(
                                    AppLocalizations.of(context).translate(
                                        "municipal_info_back_to_location"),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isManual = false;
                                      _isMunicipalitySelected = false;

                                      _resetList();
                                    });

                                    if(!isLoadingCommuniques){
                                      getCommuniques();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder(
                          future: _futureCommuniques,
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasData) {
                                if (_communiques.length > 0) {
                                  if (_currentPage == 1) {
                                    list.clear();
                                  }
                                  return _buildList(context);
                                } else {
                                  if(_municipality.isAttached){
                                    return Container(
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text(
                                              AppLocalizations.of(context).translate("municipality_info_attached_no_data").toUpperCase(),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    );
                                  }else{
                                    return Container(
                                      child: Center(
                                        child: Text(AppLocalizations.of(context)
                                            .translate(
                                            "municipality_info_no_data")
                                            .toUpperCase()),
                                      ),
                                    );
                                  }
                                }
                              }
                            }

                            return FutureCircularIndicator();
                          }),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            }
          }

          return Container(
            height: 100,
            child: FutureCircularIndicator(),
          );
        },
      ),
    );
  }

  ListView _buildList(BuildContext context) {
    return ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: _createWidgetList());
  }

  List<Widget> _createWidgetList() {
    List<Widget> list = [];

    for (var i = 0; i < _listItems.length; i++) {
      if (_listItems[i] is String) {
        list.add(_buildSeparator(_listItems[i]));
      }

      if (_listItems[i] is Communique) {
        Communique communique = _listItems[i] as Communique;
        list.add(_createDismissibleItem(communique, i, context));
      }
    }

    return list;
  }

  Widget _createDismissibleItem(Communique c, int index, BuildContext context) {
    return Dismissible(
      key: Key("${c.id.toString()}"),
      background: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.delete,
              color: Colors.white,
              size: 36.0,
            ),
          ],
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          _listItems.removeAt(index);
        });

        _foundAndDeleteSeparator(dateDeleted);
      },
      confirmDismiss: (DismissDirection direction) async {
        final result = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialog(
              title: AppLocalizations.of(context).translate("delete_communique_confirmation_title"),
              content: AppLocalizations.of(context).translate("delete_communique_confirmation_text"),
              buttonText: AppLocalizations.of(context).translate("delete").toUpperCase(),
            );
          },
        );

        setState(() {
          dateDeleted = c.date;
        });

        if (result) {
          // Comprobar si el usuario es creador del municipio o no
          // Si es creador, el comunicado se elimina para todos los usuarios,
          // Si no es creador, solo se eliminará para él
          if (_currentMunicipalityInfo.isCreator) {
            _deleteCommunique(_listItems[index], index);
          } else {
            _hideCommunique(_listItems[index], index);
          }
        }

        return result;
      },
      child: Stack(
        children: [
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: content(c),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            right: 8,
            child: Theme(
              data: Theme.of(context).copyWith(
                  buttonTheme: Theme.of(context).buttonTheme.copyWith(
                      minWidth: 0, height: 0, buttonColor: Colors.white)),
              child: RaisedButton(
                padding: EdgeInsets.all(12),
                onPressed: () {
                  onShare(context,
                      text: c.description,
                      subject:
                          'KellyFinder - ${AppLocalizations.of(context).translate("municipalInfo")}',
                      media: c.media,
                      mediaType: c.type);
                },
                child: Icon(
                  Icons.share,
                  color: AppStyles.lightGreyColor,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container _buildSeparator(String communiqueDate) {
    date = communiqueDate;

    return Container(
      height: 30,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Divider(
              color: AppStyles.lightGreyColor,
            ),
          ),
          SizedBox(width: 8),
          Text(
          communiqueDate.toSentenceCase(),
            style: TextStyle(
              color: AppStyles.lightGreyColor,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Divider(
              color: AppStyles.lightGreyColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget content(Communique communique) {
    if (communique.type == "image") {
      return CommuniqueListImage(communique: communique);
    } else if (communique.type == "text")
      return CommuniqueListText(
        communique: communique,
      );
    else if (communique.type == "video") {
      return CommuniqueListVideo(
        communique: communique,
        callback: () {
          setState(() {});
        },
      );
    } else if (communique.type == "audio") return CommuniqueListAudio(
      communique: communique
    );
    return Container();
  }

  Future _getLocation() async {
    geo.Position position = await _getCurrentLocation();

    setState(() {
      _position = position;
      _positionAux = position;
    });

    if (_position != null) {
      var result = await ApiProvider().isMunicipalitySelected({});

      setState(() {
        _isMunicipalitySelected = result['is_municipality_selected'] as bool;

        if (_isMunicipalitySelected) {
          _municipality = Municipality.fromJson(result['municipality']);
        }
      });

      _futureCommuniques = getCommuniques();

      // Init interval
      _setInterval();
      return true;
    } else {
      return false;
    }
  }

  Future _getCurrentLocation() async {
    try {
      Location location = new Location();
      location.changeSettings(accuracy: LocationAccuracy.high);

      bool _serviceEnabled = await location.serviceEnabled();

      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
      }

      if (_serviceEnabled) {
        try {
          geo.Position position = await geo.Geolocator.getCurrentPosition(
              desiredAccuracy: geo.LocationAccuracy.high);

          //_position = position;

          return position;

          /*_position = await geo.Geolocator.getCurrentPosition(
              desiredAccuracy: geo.LocationAccuracy.high);*/
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

  void _onLoading() {
    getCommuniques();
  }

  void _setInterval() {
    setState(() {
      _timer = Timer.periodic(Duration(minutes: 1), (timer) async {
        //geo.Position position = await _getCurrentLocation();

        // Solo si el municipio no está seleccionado de forma manual
        if (!_isManual && !_isMunicipalitySelected) {
          _position = await _getCurrentLocation();

          getMunicipalities();

          // Comprobar si está en movimiento
          /*if(_coordsAsString(_position.latitude, _position.longitude) !=
            _coordsAsString(position.latitude, position.longitude)){
          print("POSICIÓN DIFERENTE - ESTÁ EN RECORRIDO");
        }else{
          print("POSICIÓN IGUAL, PARADO");

          // Si detecta que la posición es igual,
          // comprobar _positionAux para saber si sigue estando parado
          // en el mismo sitio
          if(_coordsAsString(position.latitude, position.longitude) !=
              _coordsAsString(_positionAux.latitude, _positionAux.longitude)){
            print("HACEMOS EL REFRESH");
            _positionAux = position;
            // get
            _futureCommuniques = getCommuniques();
          }
        }*/
        }
      });
    });
  }

  Future getCommuniques() async {
    setState(() {
      _currentPage++;
      isLoadingCommuniques = true;
    });

    try {
      Map params = {
        "page": _currentPage,
      };

      if (_position != null) {
        if (_isManual || _isMunicipalitySelected) {
          params['municipality_id'] = _municipality.id;
        } else {
          params['lat'] = _position.latitude;
          params['lng'] = _position.longitude;
        }
      }

      MunicipalInfo _results = await ApiProvider().getMunicipalInfo(params);

      setState(() {
        _currentMunicipalityInfo = _results;
        _municipality = _results.municipality;
        switchInfo = _results.receiveMunicipalInformation;
        isLoadingCommuniques = false;
      });

      if (_results.communiques.isNotEmpty) {
        setState(() {
          _communiques.addAll(_results.communiques);

          // build list items
          for (var i = 0; i < _results.communiques.length; i++) {
            if (_results.communiques[i].date != dateAdded) {
              _listItems.add(_results.communiques[i].date);
              dateAdded = _results.communiques[i].date;
            }

            _listItems.add(_results.communiques[i]);
          }
        });

        // Refresh controller
        if (_results.communiques.length < _pageLimit) {
          _refreshController.loadNoData();
        } else {
          _refreshController.loadComplete();
        }
      } else {
        _refreshController.loadNoData();
      }

      return true;
    } catch (e) {
      catchErrors(e, _scaffoldKey);
    }
  }

  editMunicipalInfo({Municipality muni}) async {
    try {
      Map params = {"receive_municipal_information": switchInfo};

      if (muni != null) {
        params.putIfAbsent("municipality_id", () => muni.id);
      }

      MunicipalInfo _results = await ApiProvider().editMunicipalInfo(params);

      setState(() {
        _currentMunicipalityInfo = _results;
        _municipality = _results.municipality;

        _resetList();
      });

      _futureCommuniques = getCommuniques();
    } catch (e) {
      catchErrors(e, _scaffoldKey);
    }
  }

  Future getMunicipalities() async {
    try {
      Map params = {"lat": _position.latitude, "lng": _position.longitude};

      List<Municipality> _results = await ApiProvider()
          .getMunicipalitiesByDistance(params);

      if (_results.isNotEmpty) {
        if (_results[0].id != _municipality.id) {
          setState(() {
            _municipality = _results[0];

            _resetList();
          });

          _futureCommuniques = getCommuniques();
        }
      }

      return true;
    } catch (e) {
      print("error");
      catchErrors(e, _scaffoldKey);
    }
  }

  Future _deleteCommunique(Communique communique, int index) async {
    try {
      var results = await ApiProvider().deleteCommunique({}, communique.id);

      return true;
    } catch (e) {
      print("error");
      catchErrors(e, _scaffoldKey);
    }
  }

  Future _hideCommunique(Communique communique, int index) async {
    try {
      var results = await ApiProvider().hideCommunique({}, communique.id);

      return true;
    } catch (e) {
      print("error");
      catchErrors(e, _scaffoldKey);
    }
  }

  void _foundAndDeleteSeparator(String dateDeleted) {
    bool found = false;
    int indexFound;

    for (var i = 0; i < _listItems.length; i++) {
      if (_listItems[i] is Communique) {
        if (_listItems[i].date == dateDeleted) {
          found = true;
        }
      }

      if (_listItems[i] is String) {
        if (_listItems[i] == dateDeleted) {
          indexFound = i;
        }
      }
    }

    if (!found) {
      setState(() {
        _listItems.removeAt(indexFound);
      });
    }

    if (_listItems.length == 0) {
      _resetList();
      _futureCommuniques = getCommuniques();
    }
  }

  void _resetList() {
    setState(() {
      date = null;
      _currentPage = 0;
      dateAdded = null;
      _communiques.clear();
      _listItems.clear();
    });
  }
}

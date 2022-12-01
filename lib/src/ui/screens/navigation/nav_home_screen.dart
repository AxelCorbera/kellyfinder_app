import 'dart:convert';
import 'dart:developer';

import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/app_styles.dart';
import 'package:app/src/model/category.dart';
import 'package:app/src/model/lottery/get_popup_lottery.dart';
import 'package:app/src/model/municipality/communique.dart';
import 'package:app/src/model/municipality/municipality.dart';
import 'package:app/src/model/user/municipal_info.dart';
import 'package:app/src/provider/category_notifier.dart';
import 'package:app/src/provider/socket_notifier.dart';
import 'package:app/src/smtp_server/mailer.dart';
import 'package:app/src/ui/screens/communique_list/communique_list_screen.dart';
import 'package:app/src/ui/screens/lottery/christmas_lottery.dart';
import 'package:app/src/ui/widgets/button/petition_icon.dart';
import 'package:app/src/ui/widgets/button/search_slider_button.dart';
import 'package:app/src/ui/widgets/dialog/custom_dialog.dart';
import 'package:app/src/ui/widgets/grids/category_grid.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:shared_preferences/shared_preferences.dart';

class NavHomeScreen extends StatefulWidget {
  @override
  _NavHomeScreenState createState() => _NavHomeScreenState();
}

class _NavHomeScreenState extends State<NavHomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  geo.Position _position;
  geo.Position _positionAux;

  Municipality _municipality;
  MunicipalInfo _currentMunicipalityInfo;
  bool _isMunicipalitySelected = false;

  Future _futureCommuniques;
  Future _futureLocation;

  bool isLoadingCommuniques = false;
  int _currentPage = 0;
  List<Communique> _communiques = [];

  bool _isManual = false;

  bool switchInfo = false;

  Future _futureCategories;
  bool newComunique = false;
  GetPopupLottery popupLottery;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => checkLottery());
    _futureLocation = _getLocation();
    _futureCategories = _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate("home"),
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: <Widget>[
          Container(
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                if (newComunique)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 9, 3, 0),
                    child: Container(
                      alignment: Alignment.topRight,
                      child: Icon(
                        Icons.circle,
                        color: Colors.red,
                      ),
                    ),
                  ),
                Center(
                  child: IconButton(
                    color: AppStyles.lightGreyColor,
                    icon: Icon(MaterialCommunityIcons.bullhorn),
                    onPressed: () {
                      newComunique = false;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return CommuniqueListScreen();
                          },
                        ),
                      ).then((value) => {_futureLocation = _getLocation()});
                      //navigateTo(context, CommuniqueListScreen());
                    },
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            color: AppStyles.lightGreyColor,
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SingleChildScrollView(
                    child: CustomDialog(
                      title: AppLocalizations.of(context)
                              .translate("dialogCreateCard1") +
                          "\n \n" +
                          AppLocalizations.of(context)
                              .translate("dialogCreateCard2") +
                          "\n \n" +
                          AppLocalizations.of(context)
                              .translate("dialogCreateCard3"),
                      hasCancel: false,
                    ),
                  );
                },
              );
            },
          ),
          PetitionIcon(),
        ],
      ),
      body: _buildBody()
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 16),
        SearchSliderButton(
          callback: () {
            setState(() {});
          },
        ),
        Expanded(
          child: FutureBuilder(
            future: _futureCategories,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return CategoryGrid(
                    from: "search",
                  );
                }
              }
              return FutureCircularIndicator();
            },
          ),
        ),
      ],
    );
  }

  Future _getData() async {
    if (!Provider.of<CategoryNotifier>(context, listen: false).isFilled)
      try {
        List<Category> categories =
            await ApiProvider().performGetCategories({});

        Provider.of<CategoryNotifier>(context, listen: false)
            .fillCategories(categories);

        final result = await ApiProvider().performHasNewNotifications({});

        print(result);

        bool hasNewNotifications = result["has_new_requests"];
        bool hasNewChats = result["has_new_chats"];

        if (hasNewNotifications)
          Provider.of<SocketNotifier>(context, listen: false)
              .addNewNotification();

        if (hasNewChats)
          Provider.of<SocketNotifier>(context, listen: false).addNewChat(true);

        return true;
      } catch (e) {
        catchErrors(e, _scaffoldKey);
      }
    else
      return true;
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
      //_setInterval();
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

          List<dynamic> list = [];
          for (int i = 0; i < _communiques.length; i++) {
            list.add(_communiques[i].id.toString());
          }
          checkComunique(list);
        });
      } else {
        setState(() {
          newComunique = false;
          log('no hay nuevos communiques');
        });
      }

      return true;
    } catch (e) {
      catchErrors(e, _scaffoldKey);
    }
  }

  Future<void> checkComunique(List<dynamic> list) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final comRead = prefs.getString('communiques');
    // log(comRead.toString());
    // log(list.toString());
    if (comRead != null) {
      List<dynamic> com = jsonDecode(comRead);
      if (const DeepCollectionEquality().equals(list, com)) {
        newComunique = false;
        log('no hay nuevos communiques');
      } else {
        newComunique = true;
      }
    } else {
      newComunique = true;
    }
    setState(() {});
  }

  Future<void> checkLottery() async {
    try {
      final response =
      await ApiProvider().performGetEmailSettings();
      log(response);
      popupLottery = getPopupLotteryFromJson(response);
      log(popupLottery.text);
    }catch (error){
      log(error.toString());
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //await prefs.setBool('lottery', true);
    final lotteryShow = prefs.getBool('lottery');
    DateTime dateTime = DateTime.parse(popupLottery.fechaFinalizacionPopup);
    if(DateTime.now().isBefore(dateTime) && popupLottery.activarPopup == 1) {
      if (lotteryShow == null || lotteryShow) {
        Navigator.of(context).push(PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) =>
            ChristmasLottery()));
      }
    }
  }

}

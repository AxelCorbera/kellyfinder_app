import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/app_styles.dart';
import 'package:app/src/config/string_casing_extension.dart';
import 'package:app/src/model/category.dart';
import 'package:app/src/model/industrial_park/industrial_park.dart';
import 'package:app/src/provider/category_notifier.dart';
import 'package:app/src/ui/screens/add_archive/archive_company_screen.dart';
import 'package:app/src/ui/screens/industrial_park/industrial_park_categories_screen.dart';
import 'package:app/src/ui/screens/industrial_park/industrial_park_company_list_screen.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/ui/widgets/items/industrial_state_item.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class IndustrialParkSearchScreen extends StatefulWidget {
  final bool isArchive;
  final bool isSearch;
  final Category industrialParkCategory;

  const IndustrialParkSearchScreen({Key key, this.isArchive = false, this.isSearch = false, this.industrialParkCategory})
      : super(key: key);

  @override
  _IndustrialParkSearchScreenState createState() => _IndustrialParkSearchScreenState();
}

class _IndustrialParkSearchScreenState extends State<IndustrialParkSearchScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future _futureLocation;
  Future _futureWait;

  geo.Position _position;

  List<IndustrialPark> _industrialParks = [];

  RefreshController _refreshController = RefreshController(initialRefresh: false);

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
      key: _scaffoldKey,
      appBar: AppBar(centerTitle:true,
        elevation: 0,
        title: TextField(
          textInputAction: TextInputAction.search,
          onSubmitted: (value){
            setState(() {
              _currentPage = 0;
              query = value;
              _industrialParks.clear();
            });

            _futureWait = getIndustrialParks();
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(0),
            isDense: true,
            labelText: AppLocalizations.of(context).translate("searchParksTxt"),
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
      ),
      body: SmartRefresher(
        enablePullDown: false,
        enablePullUp: true,
        controller: _refreshController,
        onLoading: _onLoading,
        footer: CustomFooter(
          builder: (BuildContext context,LoadStatus mode){
            Widget body;
            if(mode==LoadStatus.idle || mode==LoadStatus.loading){
              body =  Container(
                  height: 40,
                  child: FutureCircularIndicator()
              );
            }
            else if(mode == LoadStatus.failed){
              body = Text("");
            }
            else if(mode == LoadStatus.canLoading){
              body = Text(
                AppLocalizations.of(context).translate("lazy_load_loading"),
              );
            }
            else{
              body = Text(
                AppLocalizations.of(context).translate("lazy_load_no_more"),
              );
            }
            return Container(
              height: 55.0,
              child: Center(child:body),
            );
          },
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: 8),
              /*ListTile(
                title: Text(
                 AppLocalizations.of(context).translate("industrialParksATM"),
                  style:
                      TextStyle(color: AppStyles.lightGreyColor),
                ),
              ),*/
              FutureBuilder(
                future: _futureLocation,
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if(!snapshot.data){
                      // No hay ubicación
                      return Container(
                        margin: EdgeInsets.only(top: 24.0),
                        child: Center(
                          child: Text(AppLocalizations.of(context).translate("activate_geolocation_message"), textAlign: TextAlign.center,),
                        ),
                      );
                    }else{
                      return FutureBuilder(
                        future: _futureWait,
                        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            if (snapshot.hasData) {
                              if(_industrialParks.length > 0){
                                return _buildList();
                              } else {
                                return Container(
                                    padding: EdgeInsets.all(16),
                                    child: Text(AppLocalizations.of(context).translate("industrial_park_search_no_results"))
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
      ),
    );
  }

  _buildList(){
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _industrialParks.length,
      padding: EdgeInsets.symmetric(vertical: 16),
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () {
            // Si está creando, va al formulario
            /*if (widget.isArchive) {
              navigateTo(context, ArchiveCompanyScreen());
            } else {
              navigateTo(context, IndustrialParkCompanyListScreen());
            }*/

            Provider.of<CategoryNotifier>(context, listen: false)
                .selectSubcategory(widget.industrialParkCategory);

            navigateTo(
              context,
              IndustrialParkCategoriesScreen(isArchive: widget.isArchive, industrialPark: _industrialParks[index]),
            );
          },
          child: IndustrialParkItem(industrialPark: _industrialParks[index],),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
            color: AppStyles.lightGreyColor
        );
      },
    );
  }

  Future _getLocation() async {
    await _getCurrentLocation();

    if(_position != null){
      _futureWait = getIndustrialParks();
      return true;
    }else {
      return false;
    }
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
        print("service enabled");
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

  Future getIndustrialParks() async {
    setState(() {
      _currentPage++;
    });

    try {
      print("query: $query");
      Map params = {
        "page": _currentPage,
        "lat": _position.latitude,
        "lng": _position.longitude,
        "name": query.trim(),
      };

      print("PARAMS: $params");

      List<IndustrialPark> _results = await ApiProvider().getIndustrialParks(params);

      if (_results.isNotEmpty) {
        setState(() {
          _industrialParks.addAll(_results);
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

  void _onLoading() {
    getIndustrialParks();
  }
}

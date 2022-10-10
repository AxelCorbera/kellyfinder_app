import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/app_styles.dart';
import 'package:app/src/model/category.dart';
import 'package:app/src/model/industrial_park/industrial_park.dart';
import 'package:app/src/provider/category_notifier.dart';
import 'package:app/src/ui/screens/industrial_park/industrial_park_near_screen.dart';
import 'package:app/src/ui/screens/industrial_park/industrial_park_search_screen.dart';
import 'package:app/src/ui/widgets/icon/home_icon.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/ui/widgets/items/industrial_state_item.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class IndustrialParkListScreen extends StatefulWidget {
  final bool isArchive;
  final Category industrialParkCategory;

  const IndustrialParkListScreen({Key key, this.isArchive, this.industrialParkCategory}) : super(key: key);

  @override
  _IndustrialParkListScreenState createState() => _IndustrialParkListScreenState();
}

class _IndustrialParkListScreenState extends State<IndustrialParkListScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future _futureLocation;
  Future _futureWait;

  geo.Position _position;

  List<IndustrialPark> _industrialParks = [];

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  int _currentPage = 0;
  int _pageLimit = 10;

  @override
  void initState() {
    _futureLocation = _getLocation();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CategoryNotifier category =
    Provider.of<CategoryNotifier>(context, listen: false);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(centerTitle:true,
        title: Text(AppLocalizations.of(context).translate("industrialParks"), style: TextStyle(color: Theme.of(context).accentColor),),
        iconTheme: IconThemeData(color: Theme.of(context).accentColor),
        backgroundColor: category.selectedCategory.color,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              color: AppStyles.lightGreyColor,
            ),
            onPressed: () {
              navigateTo(context, IndustrialParkSearchScreen(
                isArchive: widget.isArchive,
                industrialParkCategory: widget.industrialParkCategory,
              ));
            },
          ),
          HomeIcon(color: Colors.white,),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(context) {
    Category category =
        Provider.of<CategoryNotifier>(context, listen: false).selectedSubcategory;

    return SmartRefresher(
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
            Image.network(
              category.header,
              //"https://media.istockphoto.com/photos/new-york-city-asphalt-road-on-busy-intersection-streets-with-car-at-picture-id1133502463?k=6&m=1133502463&s=612x612&w=0&h=oTnWw3cY6j2AKWQ8efMkHEgV-N4LQFNN9gWOGM-qLEs=",
              //height: 160,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
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
                            return _buildList();
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
            //_buildList(),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      itemCount: _industrialParks.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 16),
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () {
            Provider.of<CategoryNotifier>(context, listen: false)
                .selectSubcategory(widget.industrialParkCategory);

            navigateTo(
              context,
              IndustrialParkNearScreen(
                isArchive: widget.isArchive,
                industrialPark: _industrialParks[index],
                industrialParkCategory: widget.industrialParkCategory,
              ),
            );
          },
          child: IndustrialParkItem(
            industrialPark: _industrialParks[index],
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(color: AppStyles.lightGreyColor);
      },
    );
  }

  Future _getLocation() async {
    await _getCurrentLocation();

    if(_position != null){
      _futureWait = _getIndustrialParks();
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
        print("service NOT enabled");
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

  Future _getIndustrialParks() async {
    setState(() {
      _currentPage++;
    });

    try {
      List<IndustrialPark> _results = await ApiProvider().getIndustrialParks({
        "page": _currentPage,
        "lat": _position.latitude,
        "lng": _position.longitude
      });

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

  void _onLoading() async{
    _getIndustrialParks();
  }
}

import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/app_styles.dart';
import 'package:app/src/model/municipality/autonomous_community.dart';
import 'package:app/src/model/municipality/municipality.dart';
import 'package:app/src/model/municipality/province.dart';
import 'package:app/src/ui/screens/municipality/search_municipality_screen.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/ui/widgets/items/municipality_item.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/delegates/municipality_search_delegate.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:location/location.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CommuniqueListMunicipalities extends StatefulWidget {
  final AutonomousCommunity community;

  final geo.Position position;

  const CommuniqueListMunicipalities({Key key, this.community, this.position})
      : super(key: key);

  @override
  _CommuniqueListMunicipalitiesState createState() => _CommuniqueListMunicipalitiesState();
}

class _CommuniqueListMunicipalitiesState extends State<CommuniqueListMunicipalities> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Municipality> _municipalities = [];

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  int _currentPage = 0;
  int _pageLimit = 15;

  @override
  void initState() {
    getMunicipalities();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocalizations.of(context).translate("municipalities")),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              Municipality result = await navigateTo(
                context,
                SearchMunicipalityScreen(registeredOnly: true, isSearch: true, fromCommunique: true,),
                isWaiting: true,
              );

              Navigator.pop(context, result);
            },
          ),
        ],
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
        child: _buildList(),
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      itemCount: _municipalities.length,
      padding: EdgeInsets.symmetric(vertical: 16),
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () {
            Navigator.pop(
              context,
              _municipalities[index],
            );
          },
          child: MunicipalityItem(
            municipality: _municipalities[index],
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(color: AppStyles.lightGreyColor);
      },
    );
  }

  Future getMunicipalities() async {
    setState(() {
      _currentPage++;
    });

    try {
      Map params = {
        "page": _currentPage,
        "lat": widget.position.latitude,
        "lng": widget.position.longitude,
        "is_registered": true
      };

      List<Municipality> _results = await ApiProvider().getMunicipalitiesByDistance(params);

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

  void _onLoading() async{
    print("on loading");
    getMunicipalities();
  }
}

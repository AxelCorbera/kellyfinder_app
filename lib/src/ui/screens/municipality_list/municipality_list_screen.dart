import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/app_styles.dart';
import 'package:app/src/model/municipality/autonomous_community.dart';
import 'package:app/src/model/municipality/municipality.dart';
import 'package:app/src/model/municipality/province.dart';
import 'package:app/src/ui/screens/municipality/search_municipality_screen.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/ui/widgets/items/municipality_item.dart';
import 'package:app/src/utils/delegates/municipality_search_delegate.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:location/location.dart';

class MunicipalityListScreen extends StatefulWidget {
  final AutonomousCommunity community;
  final Province province;

  final bool isCreating;

  final geo.Position position;

  const MunicipalityListScreen({Key key, this.community, this.province, this.position, this.isCreating = false})
      : super(key: key);

  @override
  _MunicipalityListScreenState createState() => _MunicipalityListScreenState();
}

class _MunicipalityListScreenState extends State<MunicipalityListScreen> {
  Future _future;

  List<Municipality> municipalities = [];

  geo.Position _position;

  @override
  void initState() {
    _future = _getMunicipalities();
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
              Municipality m = await showSearch(
                  context: context, delegate: MunicipalitySearch(municipalities));
              Navigator.pop(context, m);
            },
          ),
        ],
      ),
      body: _buildList(),
    );
  }

  Widget _buildList() {
    return FutureBuilder(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return ListView.separated(
              itemCount: municipalities.length,
              padding: EdgeInsets.symmetric(vertical: 16),
              itemBuilder: (BuildContext context, int index) {
                /*print("Municipality: ${municipalities[index].name}");
                print("Municipality distance: ${municipalities[index].distance}");*/
                return InkWell(
                  onTap: () {
                    Navigator.pop(
                      context,
                      municipalities[index],
                    );
                  },
                  child: MunicipalityItem(
                    municipality: municipalities[index],
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider(color: AppStyles.lightGreyColor);
              },
            );
          }
        }
        return FutureCircularIndicator();
      },
    );
  }

  Future _getMunicipalities() async {
    try {
      await _getCurrentLocation();

      Map params = {
        //"province_id": widget.province.id,
        /*"lat": _position.latitude,
        "lng": _position.longitude*/
      };

      if(widget.isCreating){
        params.putIfAbsent("is_registered", () => false);
      }

      if(widget.province != null){
        params.putIfAbsent("province_id", () => widget.province.id);
      }

      if(widget.position != null){
        params.putIfAbsent("lat", () => widget.position.latitude);
        params.putIfAbsent("lng", () => widget.position.longitude);
      }else{
        if(_position != null){
          params.putIfAbsent("lat", () => _position.latitude);
          params.putIfAbsent("lng", () => _position.longitude);
        }
      }

      final result = await ApiProvider().performGetMunicipalities(params);

      for (var item in result) {
        municipalities.add(Municipality.fromJson(item));
      }

      /*municipalities.add(
        Municipality.create(),
      );*/

      return true;
    } catch (e) {
      print(e);
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
}

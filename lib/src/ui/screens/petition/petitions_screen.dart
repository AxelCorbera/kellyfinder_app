import 'package:app/src/api/api_client.dart';
import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/globals.dart' as globals;
import 'package:app/src/model/petition.dart';
import 'package:app/src/provider/socket_notifier.dart';
import 'package:app/src/ui/widgets/button/petition_slider_button.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/ui/widgets/lists/petition_list.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/constants/petition_type.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:location/location.dart';

class PetitionScreen extends StatefulWidget {
  @override
  _PetitionScreenState createState() => _PetitionScreenState();
}

class _PetitionScreenState extends State<PetitionScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future _futurePetitions;

  geo.Position _position;

  @override
  void initState() {
    super.initState();

    _futurePetitions = _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(centerTitle:true,
        title: Text(AppLocalizations.of(context).translate("petitions")),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 16),
        PetitionSliderButton(
          callback: () {
            setState(() {});
          },
        ),
        Expanded(
          child: FutureBuilder(
            future: _futurePetitions,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return Consumer<SocketNotifier>(
                    builder: (context, notifier, child) {
                      return PetitionList(
                        petitions: globals.petitionType == PetitionType.RECEIVED
                            ? notifier.receivedPetitions
                            : notifier.sentPetitions,
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
          ),
        ),
      ],
    );
  }

  Future _getData() async {
    try {
      await _getCurrentLocation();

      Map params = {};

      if (_position != null) {
        params.putIfAbsent("lat", () => _position.latitude);
        params.putIfAbsent("lng", () => _position.longitude);
      }

      final result = await ApiProvider().performGetPetitions(params);

      SocketNotifier socketNotifier =
          Provider.of<SocketNotifier>(context, listen: false);

      List<Petition> sent = result["sended"]
          .map<Petition>((it) => Petition.fromJson(it))
          .toList();

      List<Petition> received = result["received"]
          .map<Petition>((it) => Petition.fromJson(it))
          .toList();

      socketNotifier.fillPetitions(sent, received);

      return true;
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
}

import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/globals.dart' as globals;
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/ui/widgets/button/search_slider_button.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/ui/widgets/lists/archive_fav_list.dart';
import 'package:app/src/ui/widgets/lists/archive_list.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/constants/searching_type.dart';
import 'package:flutter/material.dart';

class NavFavoriteScreen extends StatefulWidget {
  @override
  _NavFavoriteScreenState createState() => _NavFavoriteScreenState();
}

class _NavFavoriteScreenState extends State<NavFavoriteScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Offer> _offers;
  List<Demand> _demands;

  Future _futureFavorites;

  @override
  void initState() {
    super.initState();

    _futureFavorites = _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(centerTitle:true,
        title: Text(
          AppLocalizations.of(context).translate("favorites"),
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
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
        SearchSliderButton(
          callback: () {
            setState(() {});
          },
        ),
        Expanded(
          child: FutureBuilder(
            future: _futureFavorites,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return ArchiveFavList(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    archives: globals.searchingType == SearchingType.OFFER
                        ? _offers
                        : _demands,
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
    try {
      final result = await ApiProvider().performGetFavCards({});

      _offers = result['data']["offers"]
          .map<Offer>((it) => Offer.fromJson(it["card"]))
          .toList();

      _demands = result['data']["demands"]
          .map<Demand>((it) => Demand.fromJson(it["card"]))
          .toList();

      return true;
    } catch (e) {
      catchErrors(e, _scaffoldKey);
    }
  }
}

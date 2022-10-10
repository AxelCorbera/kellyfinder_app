import 'dart:developer';

import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/model/category.dart';
import 'package:app/src/provider/category_notifier.dart';
import 'package:app/src/ui/widgets/icon/home_icon.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/ui/widgets/items/archive/company_list_item.dart';
import 'package:app/src/ui/widgets/layout/empty_list_layout.dart';
import 'package:app/src/ui/widgets/lists/company_list.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class SafeHostelryListScreen extends StatefulWidget {
  final Category subcategory;

  const SafeHostelryListScreen({Key key, this.subcategory}) : super(key: key);

  @override
  _SafeHostelryListScreenState createState() => _SafeHostelryListScreenState();
}

class _SafeHostelryListScreenState extends State<SafeHostelryListScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Archive> archives;

  Future _futureSafe;

  geo.Position _position;

  @override
  void initState() {
    super.initState();

    _futureSafe = getByParams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(centerTitle:true,
        title: Text(widget.subcategory.name),
        actions: <Widget>[HomeIcon()],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: _buildContent(context),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    Category category = Provider.of<CategoryNotifier>(context, listen: false)
        .selectedSubcategory;

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        if (category.findSectorPic != null)
          Image.network(
            category.findSectorPic,
            fit: BoxFit.fitHeight,
            width: MediaQuery.of(context).size.width,
          ),
        FutureBuilder(
          future: _futureSafe,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                if (archives?.isNotEmpty ?? false)
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(0),
                    itemCount: archives.length,
                    itemBuilder: (BuildContext context, int index) {
                      return CompanyListItem(
                        company: archives[index],
                        category: category,
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider();
                    },
                  );

                return SizedBox(
                  height: 500,
                  child: EmptyListLayout(
                    text: AppLocalizations.of(context).translate("noResult_archives"),
                  ),
                );
              }
            }
            return SizedBox(
              height: 500,
              child: FutureCircularIndicator(),
            );
          },
        ),
      ],
    );
  }

  Future getByParams() async {
    await _getCurrentLocation();

    try {
      Map params = {
        "type": "advertising",
        "category_id": Provider.of<CategoryNotifier>(context, listen: false)
            .selectedSubcategory
            .id,
      };

      if (_position != null) {
        params.putIfAbsent("lat", () => _position.latitude);
        params.putIfAbsent("lng", () => _position.longitude);
      }

      archives = await ApiProvider().performGetByParams(params);

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

import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/model/category.dart';
import 'package:app/src/model/industrial_park/industrial_park.dart';
import 'package:app/src/model/industrial_park/industrial_park_category.dart';
import 'package:app/src/model/municipality/municipality.dart';
import 'package:app/src/model/municipality/service.dart';
import 'package:app/src/provider/category_notifier.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/widgets/icon/home_icon.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/ui/widgets/items/archive/company_list_item.dart';
import 'package:app/src/ui/widgets/layout/empty_list_layout.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:app/src/config/string_casing_extension.dart';

class MunicipalityCompanyList extends StatefulWidget {
  final Municipality municipality;
  final ServiceCategory serviceCategory;

  const MunicipalityCompanyList({Key key, this.municipality, this.serviceCategory})
      : super(key: key);

  @override
  _MunicipalityCompanyListState createState() =>
      _MunicipalityCompanyListState();
}

class _MunicipalityCompanyListState
    extends State<MunicipalityCompanyList> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Archive> _archives;

  Future _futureCompanies;

  geo.Position _position;

  @override
  void initState() {
    super.initState();

    _futureCompanies = getByParams();
  }

  @override
  Widget build(BuildContext context) {
    Category subcategory = Provider.of<CategoryNotifier>(context, listen: false)
        .selectedSubcategory;

    return Scaffold(
      appBar: AppBar(centerTitle:true,
        title: Text(
          //AppLocalizations.of(context).translate("companies"),
        widget.serviceCategory.name
        ),
        actions: <Widget>[
          HomeIcon(color: Theme.of(context).accentColor),
        ],
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
      children: <Widget>[
        FutureBuilder(
          future: _futureCompanies,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                return ListView.separated(
                  padding: EdgeInsets.only(top: 12),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _archives.length,
                  itemBuilder: (BuildContext context, int index) {
                    return CompanyListItem(
                      company: _archives[index],
                      category: category,
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider();
                  },
                );
              }
            }
            return FutureCircularIndicator();
          },
        ),
        if (_archives?.isEmpty ?? true)
          Container(
            padding: EdgeInsets.only(top: 12),
            child: EmptyListLayout(
              text: AppLocalizations.of(context).translate("noResult_archives"),
            ),
          ),
      ],
    );
  }

  Future getByParams() async {
    await _getCurrentLocation();

    try {
      Map params = {"municipality_id": widget.municipality.id, "card_advertising_category_id": widget.serviceCategory.id};

      if (_position != null) {
        params.putIfAbsent("lat", () => _position.latitude);
        params.putIfAbsent("lng", () => _position.longitude);
      }

      _archives = await ApiProvider().getMunicipalityCompanies(params);

      setState(() {});

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

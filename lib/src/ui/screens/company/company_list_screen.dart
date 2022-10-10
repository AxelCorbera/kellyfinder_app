import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/provider/category_notifier.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/screens/add_archive/archive_company_screen.dart';
import 'package:app/src/ui/widgets/icon/home_icon.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/ui/widgets/lists/company_list.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class CompanyListScreen extends StatefulWidget {
  final bool isCompany;

  const CompanyListScreen({Key key, this.isCompany = false}) : super(key: key);

  @override
  _CompanyListScreenState createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
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
    //Category category = Provider.of<CategoryNotifier>(context, listen: false)
    //.selectedSubcategory;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(centerTitle:true,
        title: Text(AppLocalizations.of(context).translate("sectorBusiness")),
        actions: <Widget>[
          HomeIcon(),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    List<Company> company =
        Provider.of<UserNotifier>(context, listen: false).appUser.companies;

    return Stack(
      children: <Widget>[
        FutureBuilder(
          future: _futureCompanies,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                return CompanyList(
                  padding:
                      EdgeInsets.fromLTRB(0, company == null ? 88 : company.isNotEmpty ? 0 : 88, 0, 0),
                  companies: _archives,
                );
              }
            }
            return FutureCircularIndicator();
          },
        ),
        if (company.isEmpty)
          Positioned(
            left: 20,
            right: 20,
            top: 20,
            child: FloatingActionButton.extended(
              heroTag: null,
              backgroundColor: Theme.of(context).accentColor,
              onPressed: () async {
                final result = await navigateTo(
                  context,
                  ArchiveCompanyScreen(fromList: true),
                  isWaiting: true,
                );


                if (result is Company) {

                  setState(() {
                    _archives.add(result);
                  });
                }
              },
              label: Text(
                AppLocalizations.of(context)
                    .translate("publishCompanyHere")
                    .toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
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

      _archives = await ApiProvider().performGetByParams(params);

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

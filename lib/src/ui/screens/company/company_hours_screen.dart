import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/model/category.dart';
import 'package:app/src/provider/category_notifier.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/screens/add_archive/archive_company_screen.dart';
import 'package:app/src/ui/widgets/icon/home_icon.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/ui/widgets/items/archive/company_list_item.dart';
import 'package:app/src/ui/widgets/layout/empty_list_layout.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:app/src/config/string_casing_extension.dart';

class CompanyHoursScreen extends StatefulWidget {
  final bool isCompany;

  const CompanyHoursScreen({Key key, this.isCompany = false}) : super(key: key);

  @override
  _CompanyHoursScreenState createState() => _CompanyHoursScreenState();
}

class _CompanyHoursScreenState extends State<CompanyHoursScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Archive> _archives;

  Future _futureCompanies;

  geo.Position _position;

  @override
  void initState() {
    print("HOLI COMPANY HOURS SCREEN");
    super.initState();

    _futureCompanies = getByParams();
  }

  @override
  Widget build(BuildContext context) {
    Category subcategory = Provider.of<CategoryNotifier>(context, listen: false)
        .selectedSubcategory;

    Category category =
        Provider.of<CategoryNotifier>(context, listen: false).selectedCategory;

    return WillPopScope(
      onWillPop: () async {
        Category subcategory = Provider.of<CategoryNotifier>(context, listen: false)
            .selectedSubcategory;

        Provider.of<CategoryNotifier>(context, listen: false).selectSubcategory(subcategory.parentCategory);

        return true;
      },
      child: Scaffold(
        appBar: AppBar(centerTitle:true,
          backgroundColor: category.color,
          iconTheme: IconThemeData(color: Theme.of(context).accentColor),
          title: Text(
    subcategory.name,
            style: TextStyle(color: Theme.of(context).accentColor),
          ),
          actions: <Widget>[
            HomeIcon(color: Theme.of(context).accentColor),
          ],
        ),
        body: _buildBody(),
      ),
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
    List<Company> company =
        Provider.of<UserNotifier>(context, listen: false).appUser.companies;

    Category category = Provider.of<CategoryNotifier>(context, listen: false)
        .selectedSubcategory;

    return Column(
      children: <Widget>[
        if (category.sector != null)
          Image.network(
            category.sector,
            fit: BoxFit.fitHeight,
            width: MediaQuery.of(context).size.width,
          ),
        if (company.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
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
        //if (_archives?.isNotEmpty ?? false)
        FutureBuilder(
          future: _futureCompanies,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                if(_archives.length == 0){
                  return Container(
                    padding: EdgeInsets.only(top: 12),
                    child: EmptyListLayout(
                      text: AppLocalizations.of(context).translate("noResult_archives"),
                    ),
                  );
                }
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
        /*if (_archives?.isEmpty ?? true)
          Container(
            padding: EdgeInsets.only(top: 12),
            child: EmptyListLayout(
              text: AppLocalizations.of(context).translate("noResult_archives"),
            ),
          ),*/
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

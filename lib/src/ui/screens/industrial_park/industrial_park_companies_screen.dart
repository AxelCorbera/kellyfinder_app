import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/industrial_park/industrial_park.dart';
import 'package:app/src/model/industrial_park/industrial_park_category.dart';
import 'package:app/src/provider/category_notifier.dart';
import 'package:app/src/ui/screens/add_archive/archive_company_screen.dart';
import 'package:app/src/ui/screens/industrial_park/industrial_park_company_list_screen.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:app/src/config/string_casing_extension.dart';

class IndustrialParkCompaniesScreen extends StatefulWidget {
  final bool isArchive;
  final IndustrialPark industrialPark;

  const IndustrialParkCompaniesScreen({Key key, this.isArchive = false, this.industrialPark})
      : super(key: key);

  @override
  _IndustrialParkCompaniesScreenState createState() => _IndustrialParkCompaniesScreenState();
}

class _IndustrialParkCompaniesScreenState extends State<IndustrialParkCompaniesScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  
  Future _futureCategories;
  
  List<IndustrialParkCategory> _categories = [];
  
  @override
  void initState() {
    _futureCategories = _getData(); 
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(centerTitle:true,
        title: Text(AppLocalizations.of(context).translate("companies")),
      ),
      body: FutureBuilder(
        future: _futureCategories,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return buildGridView();
            }
          }
          return FutureCircularIndicator();
        },
      )
    );
  }

  GridView buildGridView() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _categories.length,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () {
            if (widget.isArchive) {
              navigateTo(context, ArchiveCompanyScreen(
                //industrialParkCategory: _categories[index],
                industrialPark: widget.industrialPark,
              ));
            } else {
              navigateTo(context, IndustrialParkCompanyListScreen(
                //industrialParkCategory: _categories[index],
                industrialPark: widget.industrialPark
              ));
            }
          },
          child: Column(
            children: <Widget>[
              SizedBox(height: 4),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: new Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Image.network(_categories[index].image),
                  ),
                ),
              ),
              SizedBox(height: 4),
              Text(_categories[index].name)
            ],
          ),
        );
      },
    );
  }

  Future _getData() async {
    try {
      Map params = {};

      _categories = await ApiProvider().getIndustrialParkCategories(params);

      return true;
    } catch (e) {
      catchErrors(e, _scaffoldKey);
    }
  }
}

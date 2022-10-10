import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/globals.dart' as globals;
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/model/category.dart';
import 'package:app/src/provider/category_notifier.dart';
import 'package:app/src/ui/screens/add_archive/archive_company_screen.dart';
import 'package:app/src/ui/screens/add_archive/archive_demand_screen.dart';
import 'package:app/src/ui/screens/add_archive/archive_offer_screen.dart';
import 'package:app/src/ui/screens/category/category_screen.dart';
import 'package:app/src/ui/screens/company/company_hours_screen.dart';
import 'package:app/src/ui/widgets/dialog/custom_dialog.dart';
import 'package:app/src/ui/widgets/grids/category_hour_grid.dart';
import 'package:app/src/ui/widgets/icon/home_icon.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:app/src/config/string_casing_extension.dart';

class CategoryHoursScreen extends StatefulWidget {
  final bool isArchive;
  final bool isSubcategory;

  const CategoryHoursScreen(
      {Key key, this.isArchive, this.isSubcategory = false})
      : super(key: key);

  @override
  _CategoryHoursScreenState createState() => _CategoryHoursScreenState();
}

class _CategoryHoursScreenState extends State<CategoryHoursScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Category> _subcategories;

  Future _futureSubcategories;

  Category category;

  @override
  void initState() {
    super.initState();

    if(widget.isArchive){
      Future.delayed(Duration.zero, (){
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialog(
              title: AppLocalizations.of(context).translate("24h_popup_text"),
              hasCancel: false,
            );
          },
        );
      });
    }

    category =
        Provider.of<CategoryNotifier>(context, listen: false).selectedCategory;

    _futureSubcategories = _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: category.color,
        iconTheme: IconThemeData(color: Theme.of(context).accentColor),
        title: Text(
          category.name,
          style: TextStyle(color: Theme.of(context).accentColor),
        ),
        actions: <Widget>[HomeIcon(color: Theme.of(context).accentColor)],
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
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        if (category.header != null)
          Image.network(
            category.header,
            fit: BoxFit.fitHeight,
            width: MediaQuery.of(context).size.width,
          ),
        FutureBuilder(
          future: _futureSubcategories,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                return CategoryHourGrid(
                  categories: _subcategories,
                  callback: (Category subcategory) {
                    Provider.of<CategoryNotifier>(context, listen: false)
                        .selectSubcategory(subcategory);

                    if (subcategory.canAdvertise &&
                        globals.archiveType == Company &&
                        widget.isArchive) {
                      navigateTo(context, ArchiveCompanyScreen());
                    } else if (!subcategory.hasChild) {
                      if (!widget.isArchive) {
                        navigateTo(context, CompanyHoursScreen());
                      } else {
                        if (globals.archiveType == Offer)
                          navigateTo(context, ArchiveOfferScreen());
                        else if (globals.archiveType == Demand)
                          navigateTo(context, ArchiveDemandScreen());
                        else
                          navigateTo(context, ArchiveCompanyScreen());
                      }
                    } else {
                      navigateTo(
                        context,
                        CategoryScreen(
                          isArchive: widget.isArchive,
                          isSubcategory: true,
                        ),
                      );
                    }
                  },
                );
              }
            }
            return FutureCircularIndicator();
          },
        ),
      ],
    );
  }

  Future _getData() async {
    try {
      CategoryNotifier category =
          Provider.of<CategoryNotifier>(context, listen: false);

      _subcategories = await ApiProvider().performGetSubcategories({
        "category_id": widget.isSubcategory
            ? category.selectedSubcategory.id
            : category.selectedCategory.id,
      });

      return true;
    } catch (e) {
      catchErrors(e, _scaffoldKey);
    }
  }
}

import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/globals.dart' as globals;
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/model/category.dart';
import 'package:app/src/provider/category_notifier.dart';
import 'package:app/src/ui/widgets/grids/category_grid.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



class ArchiveCategoryScreen extends StatefulWidget {
  @override
  _ArchiveCategoryScreenState createState() => _ArchiveCategoryScreenState();
}

class _ArchiveCategoryScreenState extends State<ArchiveCategoryScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future _futureCategories;

  @override
  void initState() {
    super.initState();

    _futureCategories = _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(centerTitle:true,
          title: Text(AppLocalizations.of(context).translate("archive"))),
      body: FutureBuilder(
        future: _futureCategories,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return CategoryGrid(
                from: "archive",
                // no sirve para la modificación, hay que pasar el archiveType
                // y controlarlo desde el item
                hasDisable: globals.archiveType == Company ? false : true,
                isArchive: true,
              );
            }
          }
          return FutureCircularIndicator();
        },
      ),
    );
  }

  Future _getData() async {
    if (!Provider.of<CategoryNotifier>(context, listen: false).isFilled)
      try {
        List<Category> categories =
            await ApiProvider().performGetCategories({});

        Provider.of<CategoryNotifier>(context, listen: false)
            .fillCategories(categories);

        return true;
      } catch (e) {
        catchErrors(e, _scaffoldKey);
      }
    else
      return true;
  }
}

import 'package:app/src/api/api_provider.dart';
import 'package:app/src/model/category.dart';
import 'package:app/src/ui/widgets/grids/category_hour_grid.dart';
import 'package:app/src/ui/widgets/icon/home_icon.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/src/config/string_casing_extension.dart';

class CompanyCategoryScreen extends StatefulWidget {
  final Category category;
  final int amount;

  const CompanyCategoryScreen({Key key, this.category, this.amount})
      : super(key: key);

  @override
  _CompanyCategoryScreenState createState() => _CompanyCategoryScreenState();
}

class _CompanyCategoryScreenState extends State<CompanyCategoryScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Category> _subcategories;

  Future _futureSubcategories;

  @override
  void initState() {
    super.initState();

    _futureSubcategories = _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle:true,
        backgroundColor: widget.category.color,
        iconTheme: IconThemeData(color: Theme.of(context).accentColor),
        title: Text(
    widget.category.name,
          style: TextStyle(color: Theme.of(context).accentColor),
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
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        if (widget.category.hasHeader)
          Image.network(
            widget.category.header,
            fit: BoxFit.fitHeight,
            width: MediaQuery.of(context).size.width,
          ),
        SizedBox(height: 20),
        FutureBuilder(
          future: _futureSubcategories,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                if (widget.category.type != "24h")
                  return _buildCategory();
                else
                  return CategoryHourGrid(
                    categories: _subcategories,
                    callback: (Category subcategory) {
                      if (!subcategory.hasChild || subcategory.canAdvertise) {
                        for (int i = 0; i < widget.amount; i++) {
                          Navigator.pop(context, subcategory);
                        }
                      } else {
                        navigateTo(
                          context,
                          CompanyCategoryScreen(
                            category: subcategory,
                            amount: widget.amount + 1,
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

  Widget _buildCategory() {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _subcategories.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: FloatingActionButton(
            elevation: 4,
            backgroundColor: Theme.of(context).accentColor,
            onPressed: () {
              if (!_subcategories[index].hasChild ||
                  _subcategories[index].canAdvertise) {
                for (int i = 0; i < widget.amount; i++) {
                  Navigator.pop(context, _subcategories[index]);
                }
              } else {
                navigateTo(
                  context,
                  CompanyCategoryScreen(
                    category: _subcategories[index],
                    amount: widget.amount + 1,
                  ),
                );
              }
            },
            child: Text(
        _subcategories[index].name,
              style: TextStyle(
                color: widget.category.color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            heroTag: null,
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(height: 16);
      },
    );
  }

  Future _getData() async {
    try {
      _subcategories = await ApiProvider().performGetSubcategories({
        "category_id": widget.category.id,
      });

      return true;
    } catch (e) {
      catchErrors(e, _scaffoldKey);
    }
  }
}

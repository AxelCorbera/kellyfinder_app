import 'dart:developer';

import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/globals.dart' as globals;
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/model/category.dart';
import 'package:app/src/provider/category_notifier.dart';
import 'package:app/src/ui/screens/add_archive/archive_company_screen.dart';
import 'package:app/src/ui/screens/add_archive/archive_demand_screen.dart';
import 'package:app/src/ui/screens/add_archive/archive_offer_screen.dart';
import 'package:app/src/ui/screens/archive/archive_screen.dart';
import 'package:app/src/ui/screens/company/company_hours_screen.dart';
import 'package:app/src/ui/screens/company/company_list_screen.dart';
import 'package:app/src/ui/screens/company/safe_hostelry_list_screen.dart';
import 'package:app/src/ui/screens/industrial_park/industrial_park_list_screen.dart';
import 'package:app/src/ui/screens/municipality/route_municipality_list_screen.dart';
import 'package:app/src/ui/widgets/dialog/custom_dialog.dart';
import 'package:app/src/ui/widgets/icon/home_icon.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/alerts/handle_snack.dart';
import 'package:app/src/utils/constants/searching_type.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryScreen extends StatefulWidget {
  final bool isArchive;
  final bool isSubcategory;

  const CategoryScreen({Key key, this.isArchive, this.isSubcategory = false})
      : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Category> _subcategories;

  Map<Category,bool> hasChild = {};

  bool finding = true;

  Future _futureSubcategories;

  Category localSubcategory;

  @override
  void initState() {
    super.initState();

    _futureSubcategories = _getData();

    localSubcategory = Provider.of<CategoryNotifier>(context, listen: false)
        .selectedSubcategory;

    if(widget.isArchive){
      if(!widget.isSubcategory){
        CategoryNotifier category =
        Provider.of<CategoryNotifier>(context, listen: false);

        if(category.selectedCategory.type == "delivery"){
          Future.delayed(Duration.zero, (){
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CustomDialog(
                  title: AppLocalizations.of(context).translate("delivery_popup_text"),
                  hasCancel: false,
                );
              },
            );
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    CategoryNotifier category =
        Provider.of<CategoryNotifier>(context, listen: false);

    return WillPopScope(
      onWillPop: () async {
        if(widget.isSubcategory){
          Provider.of<CategoryNotifier>(context, listen: false).selectSubcategory(category.selectedSubcategory.parentCategory);
        }else{
          Provider.of<CategoryNotifier>(context, listen: false).selectSubcategory(category.selectedCategory.parentCategory);
        }

        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(centerTitle:true,
          backgroundColor: category.selectedCategory.color,
          iconTheme: IconThemeData(color: Theme.of(context).accentColor),
          title: Text(
            widget.isSubcategory
                ? localSubcategory.name
                : category.selectedCategory.name,
            style: TextStyle(color: Theme.of(context).accentColor),
          ),
          actions: <Widget>[
            HomeIcon(color: Theme.of(context).accentColor, isArchive: widget.isArchive,),
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
    Category category =
        Provider.of<CategoryNotifier>(context, listen: false).selectedCategory;

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        if (widget.isSubcategory) localImage(category),
        if (!widget.isSubcategory) categoryImage(category),
        SizedBox(height: 20),
        // FutureBuilder(
        //   future: _futureSubcategories,
        //   builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        //     if (snapshot.connectionState == ConnectionState.done) {
        //       if (snapshot.hasData) {
        //         if (category.type != "hostelry" || widget.isArchive)
        //           return _buildCategory();
        //         else
        //           return _buildOther(context);
        //       }
        //     }
        //     return FutureCircularIndicator();
        //   },
        // ),
            if (!finding && category.type != "hostelry" || widget.isArchive)
               _buildCategory(),
            if (!finding && category.type == "hostelry")
              _buildOther(context),
        if (finding)
          FutureCircularIndicator(),
      ],
    );
  }

  Widget _buildCategory() {
    Category category =
        Provider.of<CategoryNotifier>(context, listen: false).selectedCategory;

    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _subcategories.length,
      itemBuilder: (BuildContext context, int index) {

        if(_subcategories[index].type == "municipality" && widget.isArchive){
          return Container();
        }

        return ListTile(
          title: FloatingActionButton(
            elevation: 4,
            backgroundColor: Theme.of(context).accentColor,
            onPressed: () {
              Provider.of<CategoryNotifier>(context, listen: false)
                  .selectSubcategory(_subcategories[index]);

              _performNavigation(context, _subcategories[index]);
            },
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if(hasChild[_subcategories[index]])
                    Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.greenAccent,
                            Colors.lightBlueAccent
                          ]
                        )
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      _subcategories[index].name,
                      style: TextStyle(
                          color: category.color, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            heroTag: null,
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        if(_subcategories[index].type == "municipality" && widget.isArchive){
          return SizedBox(height: 0);
        }
        return SizedBox(height: 16);
      },
    );
  }

  Widget _buildOther(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _subcategories
                .map((item) {
                  return Expanded(child: _safeCard(item, context));
                })
                .toList()
                .cast<Widget>(),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Image.asset("assets/protocolo.png", fit: BoxFit.fitWidth),
        ),
        ListTile(
          dense: true,
          title: Text(
            AppLocalizations.of(context).translate("hostelryDesc"),
            textAlign: TextAlign.justify,
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _safeCard(Category item, BuildContext context) {
    Category category =
        Provider.of<CategoryNotifier>(context, listen: false).selectedCategory;

    return Card(
      child: Material(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () {
            Provider.of<CategoryNotifier>(context, listen: false)
                .selectSubcategory(item);

            navigateTo(context, SafeHostelryListScreen(subcategory: item));
          },
          child: Column(
            children: <Widget>[
              Image.network(item.image),
              Container(
                height: 60,
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: AutoSizeText(
                    item.name,
                    maxLines: 2,
                    minFontSize: 4,
                    maxFontSize: 16,
                    style: TextStyle(color: category.color),
                    textAlign: TextAlign.center,
                    wrapWords: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _getData() async {
    try {
      CategoryNotifier category =
          Provider.of<CategoryNotifier>(context, listen: false);

      Map params = {
        "category_id": widget.isSubcategory
            ? category.selectedSubcategory.id
            : category.selectedCategory.id,
      };

      _subcategories = await ApiProvider().performGetSubcategories(params);
      await findChild();
      setState(() {

      });

      return true;
    } catch (e) {
      catchErrors(e, _scaffoldKey);
      setState(() {
        hasChild = {};
        finding = false;
      });
    }
  }

  Widget localImage(Category category) {
    if (localSubcategory?.hasHeader ?? false)
      return Image.network(
        localSubcategory.header,
        fit: BoxFit.fitHeight,
        width: MediaQuery.of(context).size.width,
      );
    else if (localSubcategory?.hasSector ?? false)
      return InkWell(
        onTap: () {
          // No abrir CompanyListScreen si es compartidos
          if (category.type != "shared")
            navigateTo(context, CompanyListScreen());
        },
        child: Image.network(
          localSubcategory.sector,
          fit: BoxFit.fitHeight,
          width: MediaQuery.of(context).size.width,
        ),
      );
    else
      return Container();
  }

  Widget categoryImage(Category category) {
    if (category.hasHeader)
      return Image.network(
        category.header,
        fit: BoxFit.fitHeight,
        width: MediaQuery.of(context).size.width,
      );
    else if (category.hasSector)
      return InkWell(
        onTap: () {
          if (category.type != "shared")
            navigateTo(context, CompanyListScreen());
        },
        child: Image.network(
          category.sector,
          fit: BoxFit.fitHeight,
          width: MediaQuery.of(context).size.width,
        ),
      );
    else
      return Container();
  }

  void _performNavigation(BuildContext context, Category subcategory) {
    Category category =
        Provider.of<CategoryNotifier>(context, listen: false).selectedCategory;

    bool willCreate = subcategory.canAdvertise &&
        globals.archiveType == Company &&
        widget.isArchive;

    /*print("CAN ADVERTISE: ${subcategory.canAdvertise}");
    print("globals.archiveType: ${globals.archiveType}");
    print("widget.isArchive: ${widget.isArchive}");

    print("-----");

    print("WILL CREATE: $willCreate");

    print("Category.type: ${category.type}");
    print("Subcategory.type: ${subcategory.type}");

    print("subcategory.hasChild: ${subcategory.hasChild}");*/

    if (willCreate) {

      navigateTo(context, ArchiveCompanyScreen());
    } else if (!subcategory.hasChild) {
      if (!widget.isArchive) {
        if (category.type == "24h")
          navigateTo(context, CompanyHoursScreen());
        else if (category.type == "delivery")
          navigateTo(context, SafeHostelryListScreen(subcategory: subcategory));
        else if (category.type == "route") {

          if (subcategory.type == "municipality") {

            navigateTo(context,
                RouteMunicipalityListScreen(isArchive: widget.isArchive));
          } else if (subcategory.type == "industrial_park") {
            navigateTo(
                context, IndustrialParkListScreen(isArchive: widget.isArchive));
          }
        } else
          navigateTo(context, ArchiveScreen());
      } else {
        if (globals.archiveType == Offer)
          navigateTo(context, ArchiveOfferScreen());
        else if (globals.archiveType == Demand)
          navigateTo(context, ArchiveDemandScreen());
        else {
          if (category.type == "route") {
            if (subcategory.type == "municipality") {
              if (!widget.isArchive) {
                navigateTo(context,
                    RouteMunicipalityListScreen(isArchive: widget.isArchive));
              }
            } else if (subcategory.type == "industrial_park") {
              navigateTo(context,
                  IndustrialParkListScreen(isArchive: widget.isArchive));
            }
          } else
            navigateTo(context, ArchiveCompanyScreen());
        }
      }
    } else {

      if(subcategory.type == "industrial_park"){
        navigateTo(
            context, IndustrialParkListScreen(isArchive: widget.isArchive, industrialParkCategory: subcategory,));
      }else{
        navigateTo(
          context,
          CategoryScreen(
            isArchive: widget.isArchive,
            isSubcategory: true,
          ),
        );
      }
    }
  }

  findChild() async{
    CategoryNotifier category =
    Provider.of<CategoryNotifier>(context, listen: false);

    for(int i = 0; i<_subcategories.length;i++){
      Map<String,String> params2 = {
        "id_categoria":_subcategories[i].id.toString(),
        "tipo":
        globals.searchingType ==SearchingType.OFFER ? "1" : "2",
      };

      final test = await ApiProvider().comprobarNumCards(params2);

      if(test.num_cards == 0) {
        hasChild[_subcategories[i]] = false;
      }else{
        hasChild[_subcategories[i]] = true;
      }

      log('category: '+ category.selectedCategory.type +' > '+test.toString());
    }
    finding = false;

    // CategoryNotifier category =
    // Provider.of<CategoryNotifier>(context, listen: false);
    //
    // for(int i = 0; i<_subcategories.length;i++){
    //   Map params2 = {
    //     "type":
    //     category.selectedCategory.type == 'delivery'? "advertising" :
    //     globals.searchingType ==SearchingType.DEMAND ? "demand" : "offer",
    //     "category_id": _subcategories[i].id,
    //   };
    //
    //   final test = await ApiProvider().test(params2);
    //
    //   hasChild[_subcategories[i]] = test;
    //
    //   log('category: '+ category.selectedCategory.type +' > '+test.toString());
    // }
    // finding = false;
  }
}

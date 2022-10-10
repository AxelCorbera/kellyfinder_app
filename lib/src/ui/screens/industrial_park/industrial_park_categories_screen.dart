import 'dart:developer';

import 'package:app/src/api/api_provider.dart';
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/model/category.dart';
import 'package:app/src/model/industrial_park/industrial_park.dart';
import 'package:app/src/provider/category_notifier.dart';
import 'package:app/src/ui/screens/add_archive/archive_company_screen.dart';
import 'package:app/src/ui/screens/industrial_park/industrial_park_company_list_screen.dart';
import 'package:app/src/ui/widgets/icon/home_icon.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/constants/searching_type.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:app/src/config/globals.dart' as globals;
import 'package:geolocator/geolocator.dart' as geo;


class IndustrialParkCategoriesScreen extends StatefulWidget {
  final bool isArchive;
  final IndustrialPark industrialPark;

  const IndustrialParkCategoriesScreen({Key key, this.isArchive, this.industrialPark})
      : super(key: key);

  @override
  _IndustrialParkCategoriesScreenState createState() => _IndustrialParkCategoriesScreenState();
}

class _IndustrialParkCategoriesScreenState extends State<IndustrialParkCategoriesScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Category> _subcategories;

  Future _futureSubcategories;

  Map<Category,bool> hasChild = {};

  bool finding = true;

  geo.Position _position;

  List<Archive> _archives;

  @override
  void initState() {

    _futureSubcategories = _getData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    Category category =
        Provider.of<CategoryNotifier>(context, listen: false).selectedCategory;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(centerTitle:true,
        backgroundColor: category.color,
        iconTheme: IconThemeData(color: Theme.of(context).accentColor),
        title: Text(
            Provider.of<CategoryNotifier>(context, listen: false).selectedSubcategory.name,
          style: TextStyle(
            color: Theme.of(context).accentColor,
          ),
        ),
        actions: <Widget>[
          HomeIcon(
            color: Colors.white,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: _buildBody(context),
      )
      //body: _buildBody(context),
    );
  }

  Widget _buildBody(context) {
    Category category =
        Provider.of<CategoryNotifier>(context, listen: false).selectedSubcategory;

    return Column(
      children: <Widget>[
        Image.network(
          category.header,
          //"https://media.istockphoto.com/photos/new-york-city-asphalt-road-on-busy-intersection-streets-with-car-at-picture-id1133502463?k=6&m=1133502463&s=612x612&w=0&h=oTnWw3cY6j2AKWQ8efMkHEgV-N4LQFNN9gWOGM-qLEs=",
          fit: BoxFit.fitHeight,
          width: MediaQuery.of(context).size.width,
        ),
        SizedBox(height: 20),
        // FutureBuilder(
        //   future: _futureSubcategories,
        //   builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        //     if (snapshot.connectionState == ConnectionState.done) {
        //       if (snapshot.hasData) {
        //         return _buildCategory(context);
        //       }
        //     }
        //     return FutureCircularIndicator();
        //   },
        // ),
        if (!finding)
          _buildCategory(context),
        if (finding)
          FutureCircularIndicator(),
      ],
    );
  }

  Widget _buildCategory(context) {
    Category category =
        Provider.of<CategoryNotifier>(context, listen: false).selectedCategory;

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

              Provider.of<CategoryNotifier>(context, listen: false)
                  .selectSubcategory(_subcategories[index]);

              _performNavigation(context, _subcategories[index]);

              // Aquí se debe comprobar si tiene más subcategorías anidadas

              /*navigateTo(
                context,
                IndustrialParkCompaniesScreen(isArchive: widget.isArchive),
              );*/
            },
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
                Center(
                  child: Text(
                    //AppLocalizations.of(context).translate("companies"),
                    _subcategories[index].name,
                    style: TextStyle(
                      color: category.color,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
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
      CategoryNotifier category =
      Provider.of<CategoryNotifier>(context, listen: false);

      Map params = {
        "category_id": category.selectedSubcategory.id
      };

      _subcategories = await ApiProvider().performGetSubcategories(params);
      await fChild(_subcategories, category.selectedSubcategory.id.toString());

      setState(() {
        log('FINDING FALSE');
        finding = false;
      });
      return true;
    } catch (e) {
      hasChild = {};
      catchErrors(e, _scaffoldKey);
    }
  }

  void _performNavigation(BuildContext context, Category subcategory) {
    // Si tiene más subcategorías
    if(subcategory.hasChild){
      navigateTo(
        context,
        IndustrialParkCategoriesScreen(
          isArchive: widget.isArchive,
          industrialPark: widget.industrialPark,
          //isSubcategory: true,
        ),
      );
    }else{
      if (widget.isArchive) {

        navigateTo(context, ArchiveCompanyScreen(
          industrialParkCategory: subcategory,
          industrialPark: widget.industrialPark,
        ));
      } else {
        navigateTo(context, IndustrialParkCompanyListScreen(
            industrialParkCategory: subcategory,
            industrialPark: widget.industrialPark
        ));
      }
      /*navigateTo(
        context,
        IndustrialParkCompaniesScreen(isArchive: widget.isArchive, industrialPark: widget.industrialPark,),
      );*/
    }
  }

  Future fChild(List<Category> subcategories,String idCategory) async{

    for(int i = 0; i< _subcategories.length;i++){
      Map<String,String> params2 = {
        "id_categoria": idCategory,
        "id_poligono": _subcategories[i].id.toString(),
        "tipo":
        globals.searchingType ==SearchingType.OFFER ? "1" : "2",
      };
      final getChild = await ApiProvider().comprobarNumCardsPoligonos(params2);
      log(getChild.toString());
      if(getChild.num_cards>0){
        hasChild[_subcategories[i]] = true;
      }else{
        hasChild[_subcategories[i]] = false;
      }
      }


    // for(int i = 0; i< _subcategories.length;i++){
    //   if(subcategories[i].hasChild) {
    //      final response = await fSubCategories(subcategories[i]);
    //      hasChild[_subcategories[i]] = response;
    //   }else{
    //     final response = await getByParams(subcategories[i].id.toString());
    //     hasChild[_subcategories[i]] = response;
    //   }
    // }
  }

  Future<bool> fSubCategories(Category subcat) async {
    // Map params = {
    //   "category_id": subcat.id,
    // };

    // final subcategories2 = await ApiProvider().performGetSubcategories(
    //     params);

    Map<String,String> params2 = {
      "id_categoria": subcat.id.toString(),
      "tipo":
      globals.searchingType ==SearchingType.OFFER ? "1" : "2",
    };
    final getChild = await ApiProvider().comprobarNumCards(params2);
    if(getChild.num_cards>0){
      return true;
    }else{
      return false;
    }
    // bool r = false;
    // for(int i = 0; i< subcategories2.length;i++){
    //   if(subcategories2[i].hasChild) {
    //     return await fSubCategories(subcategories2[i]);
    //   }else{
    //     final response = await getByParams(subcategories2[i].id.toString());
    //     if(response)
    //       r=true;
    //     return r;
    //   }
    // }
  }

  Future<bool> getByParams(String industrialParkCategoryId) async {
    await _getCurrentLocation();

    try {
      Map params = {"industrial_park_id": widget.industrialPark.id, "category_id": industrialParkCategoryId};

      if (_position != null) {
        params.putIfAbsent("lat", () => _position.latitude);
        params.putIfAbsent("lng", () => _position.longitude);
      }

      _archives = await ApiProvider().getIndustrialParkCompanies(params);
      log(_archives[0].id.toString());
      if(_archives.isNotEmpty){
        return true;
      }else{
        return false;
      }
      return true;
    } catch (e) {
      catchErrors(e, _scaffoldKey);
      return false;
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

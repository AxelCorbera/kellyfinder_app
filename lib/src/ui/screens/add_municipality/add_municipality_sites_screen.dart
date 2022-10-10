import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/municipality/service.dart';
import 'package:app/src/ui/widgets/button/custom_button.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/src/config/string_casing_extension.dart';

class AddMunicipalitySitesScreen extends StatefulWidget {
  @override
  _AddMunicipalitySitesScreenState createState() =>
      _AddMunicipalitySitesScreenState();
}

class _AddMunicipalitySitesScreenState
    extends State<AddMunicipalitySitesScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future _futureCategories;

  List<Service> _services = [];

  @override
  void initState() {
    _futureCategories = getCategories();

    Future.delayed(Duration(seconds: 0), () async {
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                AppLocalizations.of(context).translate("fillNeighbors"),
                style: Theme.of(context).textTheme.subtitle1,
              ),
              actions: <Widget>[
                SimpleDialogOption(
                  child: Text(
                    AppLocalizations.of(context)
                        .translate("close")
                        .toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                ),
              ],
            );
          });

      Navigator.pop(context);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(centerTitle:true,
        title: Text(
          AppLocalizations.of(context).translate("publishMunicipality"),
        ),
      ),
      body: FutureBuilder(
          future: _futureCategories,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                return _buildBody();
              }
            }

            return FutureCircularIndicator();
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CustomButton(
        text: AppLocalizations.of(context).translate("save"),
        function: () {},
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _buildServiceItems(),
    );
  }

  List<Widget> _buildServiceItems(){
    return _services.map<Widget>((service) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
            service.name,
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: service.categories.length,
              padding: EdgeInsets.all(16),
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: (){

                    //widget.callback(service.categories[index]);
                    //Navigator.pop(context);
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      //color: Theme.of(context).primaryColorLight.withOpacity(0.4),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    child: Image.network(service.categories[index].image),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(width: 8);
              },
            ),
          ),
        ],
      );
    }).toList();
  }

  Future getCategories() async {
    try {
      _services = await ApiProvider().getMunicipalityServices({});

      return true;
    } catch (e) {
      catchErrors(e, _scaffoldKey);
    }
  }
}

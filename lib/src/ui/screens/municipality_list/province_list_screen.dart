import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/app_styles.dart';
import 'package:app/src/model/municipality/autonomous_community.dart';
import 'package:app/src/model/municipality/province.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/src/config/string_casing_extension.dart';

class ProvinceListScreen extends StatefulWidget {
  final AutonomousCommunity community;

  const ProvinceListScreen({Key key, this.community}) : super(key: key);

  @override
  _ProvinceListScreenState createState() => _ProvinceListScreenState();
}

class _ProvinceListScreenState extends State<ProvinceListScreen> {
  Future _future;
  List<Province> _provinces = [];

  @override
  void initState() {
    _future = _getProvinces();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate("provinces"),
        ),
      ),
      body: _buildList(),
    );
  }

  Widget _buildList() {
    return FutureBuilder(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return ListView.separated(
              itemCount: _provinces.length,
              padding: EdgeInsets.symmetric(vertical: 16),
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    Navigator.pop(context, _provinces[index]);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                      _provinces[index].name,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)
                          ),
                          child: Image.network(
                            //"https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Flag_of_Andalusia_%28simple%29.svg/1200px-Flag_of_Andalusia_%28simple%29.svg.png",
                            _provinces[index].flag,
                            height: 56,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider(color: AppStyles.lightGreyColor);
              },
            );
          }
        }

        return FutureCircularIndicator();
      },
    );
  }

  Future _getProvinces() async {
    try {
      final result  = await ApiProvider().performGetProvinces({
        "community_id": widget.community.id,
      });

      for (var item in result) {
        _provinces.add(Province.fromJson(item));
      }

      return true;
    } catch (e) {
      print(e);
    }
  }
}

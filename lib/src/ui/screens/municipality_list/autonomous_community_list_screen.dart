import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/app_styles.dart';
import 'package:app/src/model/municipality/autonomous_community.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/src/config/string_casing_extension.dart';

class AutonomousCommunityListScreen extends StatefulWidget {
  @override
  _AutonomousCommunityListScreenState createState() =>
      _AutonomousCommunityListScreenState();
}

class _AutonomousCommunityListScreenState
    extends State<AutonomousCommunityListScreen> {
  Future _future;

  List<AutonomousCommunity> _communities = [];

  @override
  void initState() {
    _future = _getCommunities();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate("autonomousCommunity"),
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
              itemCount: _communities.length,
              padding: EdgeInsets.symmetric(vertical: 16),
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    Navigator.pop(context, _communities[index]);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                      _communities[index].name,
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
                            _communities[index].flag,
                            //"https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Flag_of_Andalusia_%28simple%29.svg/1200px-Flag_of_Andalusia_%28simple%29.svg.png",
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

  Future _getCommunities() async {
    try {
      final result = await ApiProvider().performGetCommunities({});

      for (var item in result) {
        _communities.add(AutonomousCommunity.fromJson(item));
      }

      return true;
    } catch (e) {
      print(e);
    }
  }
}

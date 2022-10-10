import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/municipality/municipality.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/ui/widgets/items/municipality_item.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MunicipalityFutureSearch extends SearchDelegate<Municipality> {
  final List<Municipality> listWords;

  List<Municipality> _municipalities = [];

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  int _currentPage = 0;
  int _pageLimit = 10;

  MunicipalityFutureSearch(this.listWords);

  @override
  List<Widget> buildActions(BuildContext context) {
    //Actions for app bar
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    //leading icon on the left of the app bar
    return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    _currentPage = 0;
    _municipalities.clear();

    return _buildFutureList();
  }

  FutureBuilder<List<Municipality>> _buildFutureList() {
    return FutureBuilder<List<Municipality>>(
      future: getMunicipalities(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return SmartRefresher(
            enablePullDown: false,
            enablePullUp: true,
            controller: _refreshController,
            onLoading: _onLoading,
            footer: CustomFooter(
              builder: (BuildContext context, LoadStatus mode) {
                Widget body;
                if (mode == LoadStatus.idle || mode == LoadStatus.loading) {
                  body =
                      Container(height: 40, child: FutureCircularIndicator());
                } else if (mode == LoadStatus.failed) {
                  body = Text("");
                } else if (mode == LoadStatus.canLoading) {
                  body = Text(
                    AppLocalizations.of(context).translate("lazy_load_loading"),
                  );
                } else {
                  body = Text(
                    AppLocalizations.of(context).translate("lazy_load_no_more"),
                  );
                }
                return Container(
                  height: 55.0,
                  child: Center(child: body),
                );
              },
            ),
            child: ListView.builder(
              itemBuilder: (context, index) => ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
                  onTap: () {
                    Navigator.pop(
                      context,
                      snapshot.data[index],
                    );
                  },
                  title: InkWell(
                    onTap: () {
                      Navigator.pop(
                        context,
                        snapshot.data[index],
                      );
                    },
                    child: MunicipalityItem(
                      municipality: snapshot.data[index],
                    ),
                  )),
              itemCount: snapshot.data != null ? snapshot.data.length : 0,
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }

  Future<List<Municipality>> getMunicipalities() async {
    _currentPage++;

    try {
      List<Municipality> _results = await ApiProvider()
          .getMunicipalitiesByDistance({"page": _currentPage, "name": query});

      if (_results.isNotEmpty) {
        _municipalities.addAll(_results);

        if (_municipalities.length < _pageLimit) {
          _refreshController.loadNoData();
        } else {
          _refreshController.loadComplete();
        }
      } else {
        _refreshController.loadNoData();
      }

      return _municipalities;
    } catch (e) {
      print("error");
      return null;
    }
  }

  void _onLoading() async {
    getMunicipalities();
  }
}

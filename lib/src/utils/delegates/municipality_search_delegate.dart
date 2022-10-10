import 'package:app/src/model/municipality/municipality.dart';
import 'package:app/src/ui/widgets/items/municipality_item.dart';
import 'package:flutter/material.dart';

class MunicipalitySearch extends SearchDelegate<Municipality> {
  final List<Municipality> listWords;

  MunicipalitySearch(this.listWords);

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
    // show some result based on the selection
    return filterList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // show when someone searches for something



    return filterList();
  }

  ListView filterList() {
    final suggestionList = query.isEmpty
        ? listWords
        : listWords
        .where((p) => p.name.contains(RegExp(query, caseSensitive: false)))
        .toList();

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
          onTap: () {
            Navigator.pop(
              context,
              suggestionList[index],
            );
          },
          title: InkWell(
            onTap: () {
              Navigator.pop(
                context,
                suggestionList[index],
              );
            },
            child: MunicipalityItem(
              municipality: suggestionList[index],
            ),
          )),
      itemCount: suggestionList.length,
    );
  }
}
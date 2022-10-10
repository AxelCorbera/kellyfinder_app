import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/municipality/municipality.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/src/config/string_casing_extension.dart';

class MunicipalityItem extends StatelessWidget {

  final Municipality municipality;

  MunicipalityItem({this.municipality});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                /*AutoSizeText(
                  municipality.community.name,
                  style: Theme.of(context).textTheme.subtitle1,
                  maxLines: 1,
                  minFontSize: 4,
                  textAlign: TextAlign.center,
                  wrapWords: false,
                ),*/
                Text(
              municipality.community.name,
                  style: Theme.of(context).textTheme.subtitle1,
                  //maxLines: 1,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                  child: Image.network(
                    municipality.community.flag,
                    //"https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Flag_of_Andalusia_%28simple%29.svg/1200px-Flag_of_Andalusia_%28simple%29.svg.png",
                    width: 88,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  /*AutoSizeText(
                    municipality.name,
                    maxLines: 2,
                    minFontSize: 4,
                    style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                    wrapWords: false,
                  ),*/
                  Text(
                      municipality.name,
                    //maxLines: 2,
                    style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.w600),
                    //textScaleFactor: 1.0,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  if(municipality?.distance != null)
                  Text(
                    AppLocalizations.of(context).translate("municipality_to_distance") + " ${municipality.distance} km",
                    style: Theme.of(context).textTheme.subtitle1.copyWith(
                          color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                        ),
                    //textScaleFactor: 1.0,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
    municipality.province.name,
                  style: Theme.of(context).textTheme.subtitle1,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                  child: Image.network(
                    //"https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Flag_of_Andalusia_%28simple%29.svg/1200px-Flag_of_Andalusia_%28simple%29.svg.png",
                    municipality.province.flag,
                    width: 88,
                    //width: 50,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/industrial_park/industrial_park.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class IndustrialParkItem extends StatelessWidget {
  final IndustrialPark industrialPark;

  IndustrialParkItem({this.industrialPark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    /*AutoSizeText(
                      industrialPark.municipality.community.name,
                      style: Theme.of(context).textTheme.subtitle1,
                      maxLines: 1,
                      minFontSize: 4,
                      textAlign: TextAlign.center,
                      wrapWords: false,
                    ),*/
                    Text(
                      industrialPark.municipality.community.name,
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
                        industrialPark.municipality.community.flag,
                        //"https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Flag_of_Andalusia_%28simple%29.svg/1200px-Flag_of_Andalusia_%28simple%29.svg.png",
                        width: 88,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "${industrialPark.type?.name}".toUpperCase(),
                        style: Theme.of(context).textTheme.subtitle2.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      /*AutoSizeText(
                        industrialPark.name,
                        maxLines: 1,
                        minFontSize: 4,
                        style: Theme.of(context).textTheme.subtitle1,
                        textAlign: TextAlign.center,
                        wrapWords: false,
                      ),*/
                      Text(
                        /*"Cruïlles, Monells I Sant Sadurní de L´heura",*/
                        industrialPark.name,
                        style: Theme.of(context).textTheme.subtitle1,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        industrialPark.municipality.name,
                        style: Theme.of(context).textTheme.subtitle1,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      if(industrialPark?.distance != null)
                      Text(
                        AppLocalizations.of(context).translate("municipality_to_distance") + " ${industrialPark.distance} km",
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
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
                      industrialPark.municipality.province.name,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey)
                      ),
                      child: Image.network(
                        industrialPark.municipality.province.flag,
                        //"https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Flag_of_Andalusia_%28simple%29.svg/1200px-Flag_of_Andalusia_%28simple%29.svg.png",
                        width: 88,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/municipality/service.dart';
import 'package:flutter/material.dart';

class MunicipalitySites extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            AppLocalizations.of(context).translate("whereToEat"),
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
            itemCount: 5,
            padding: EdgeInsets.all(16),
            itemBuilder: (BuildContext context, int index) {
              return Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorLight.withOpacity(0.4),
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(width: 8);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            AppLocalizations.of(context).translate("whereToSleep"),
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
            itemCount: 5,
            padding: EdgeInsets.all(16),
            itemBuilder: (BuildContext context, int index) {
              return Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorLight.withOpacity(0.4),
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(width: 8);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            AppLocalizations.of(context).translate("others"),
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
            itemCount: 5,
            padding: EdgeInsets.all(16),
            itemBuilder: (BuildContext context, int index) {
              return Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorLight.withOpacity(0.4),
                  borderRadius: BorderRadius.all(Radius.circular(4)),
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
  }
}

import 'dart:io';

import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/ui/widgets/image/custom_logo.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class InfoScreen extends StatefulWidget {
  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  List<Widget> info = [];

  Future _future;
  String appVersion = "";

  @override
  void initState() {

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        appVersion = packageInfo.version;
      });
    });


    _future = _getDeviceInfo();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle:true,
        title: Text(AppLocalizations.of(context).translate("info")),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          SizedBox(height: 28),
          CustomLogo(),
          SizedBox(height: 16),
          Text(
            "${AppLocalizations.of(context).translate("version")}: $appVersion",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          SizedBox(height: 4),
          FutureBuilder(
              future: _future,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    return Column(
                      children: info,
                    );
                  }
                }

                return FutureCircularIndicator();
              }),
          SizedBox(height: 16.0,),
          ListTile(
            title: Text(
              AppLocalizations.of(context).translate("info1"),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
          SizedBox(height: 16),
          ListTile(
            title: Text(
              AppLocalizations.of(context).translate("info2"),
              style: Theme.of(context).textTheme.bodyText2,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16),
          ListTile(
            title: Text(
              AppLocalizations.of(context).translate("info3"),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
          SizedBox(height: 16),
          ListTile(
            title: Text(
              AppLocalizations.of(context).translate("info4"),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
        ],
      ),
    );
  }

  Future _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if(Platform.isAndroid){
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      info.add(Text("Versión Android: ${androidInfo.version.baseOS}"));
    }else{
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      info.add(Text("Versión iOS: ${iosInfo.systemVersion}"));
    }

    return true;

  }
}

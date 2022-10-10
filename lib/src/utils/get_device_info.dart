import 'dart:io';

import 'package:app/src/api/api_provider.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';

Future<void> getDeviceInfo() async {
  Map<String, dynamic> deviceData;
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  try {
    if (Platform.isAndroid) {
      deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
    } else if (Platform.isIOS) {
      deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
    }

    ApiProvider().setDeviceInfo(deviceData);
  } on PlatformException {
    deviceData = <String, dynamic>{
      'Error:': 'Failed to get platform version.'
    };
  }
}

Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
  return <String, dynamic>{
    'device_os': 1,
    "app_version": "1.0.0",
    "device_os_version": build.version.sdkInt
  };
}

Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
  return <String, dynamic>{
    'device_os': 2,
    "app_version": "1.0.0",
    "device_os_version": data.systemVersion
  };
}
import 'dart:io';

import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/municipality/communique.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:http/http.dart' as http;

String coordsAsString(double lat, double lng) {
  int decimalLat = int.parse(lat.toString().split("\.")[0]);
  int fractionalLat = int.parse(lat.toString().split("\.")[1]);

  int decimalLng = int.parse(lng.toString().split("\.")[0]);
  int fractionalLng = int.parse(lng.toString().split("\.")[1]);

  String latStr = "$decimalLat.${fractionalLat.toString().substring(0, 3)}";
  String lngStr = "$decimalLng.${fractionalLng.toString().substring(0, 3)}";

  String result = "$latStr,$lngStr";

  return result;
}

void onShare(BuildContext context, {String text, String subject, String media, String mediaType}) async {
  if (mediaType != "text") {
    final RenderBox box = context.findRenderObject();

    var url = media;

    var response = await http.get(url);
    // si no funciona en android, poner getExternalStorageDirectory()
    final documentDirectory = (await getTemporaryDirectory()).path;

    String fileExtension;

    if (mediaType == "image") {
      fileExtension = "png";
    }

    if (mediaType == "video") {
      fileExtension = "mp4";
    }

    if (mediaType == "audio") {
      fileExtension = "wav";
    }

    DateTime dateTime = DateTime.now();

    String filePath =
        '$documentDirectory/media${dateTime.toString()}.$fileExtension';

    File imgFile = new File(filePath);

    imgFile.writeAsBytesSync(response.bodyBytes);

    Share.shareFiles([File(filePath).path],
        subject: subject,
        text: text,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  } else {
    Share.share(
      text,
      subject: subject
    );
  }
}
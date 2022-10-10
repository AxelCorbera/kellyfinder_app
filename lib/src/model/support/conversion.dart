import 'package:app/src/model/archive/archive.dart';
import 'package:flutter/material.dart';

class Conversion {
  static bool intToBool(dynamic jsonVal) {
    return jsonVal is bool ? jsonVal : jsonVal == 1 ? true : false;
  }

  static Color stringToColor(dynamic jsonVal) {
    if (jsonVal != null && jsonVal != "null") {
      var e = "0xFF" + jsonVal;

      return Color(int.parse(e));
    }
    return null;
  }

  static String colorToString(Color jsonVal) {
    return "${jsonVal?.value}";
  }

  static double stringToDouble(dynamic jsonVal) {
    if (jsonVal != null) {
      if (jsonVal is double)
        return jsonVal;
      else
        return double.parse(jsonVal);
    }

    return null;
  }

  static objectToJson(dynamic jsonVal) {
    return jsonVal?.toJson();
  }

  static listToJson(dynamic jsonVal) {
    return jsonVal.map((it) => it.toJson()).toList();
  }

  static Archive typeToArchive(dynamic jsonVal) {
    if (jsonVal != null) {
      if (jsonVal["type"] == "offer") {
        return Offer.fromJson(jsonVal);
      } else if (jsonVal["type"] == "demand") {
        return Demand.fromJson(jsonVal);
      } else {
        return Company.fromJson(jsonVal);
      }
    }

    return null;
  }
}

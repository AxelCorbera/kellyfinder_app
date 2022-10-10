import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as _http;
import 'package:url_launcher/url_launcher.dart';

class MapDirectionsApi {
  final googleApiUrl = "maps.googleapis.com";
  final key = "AIzaSyCnzbXoAE0ArwUymw4nNTYd4Oacw6lDh7U";

  Future<List> getCities(String pattern, String lang) async {
    final queryParams = {
      "input": pattern,
      "language": lang,
      "types": "(cities)",
      "key": key,
      "sessionToken": getRandomString(10),
    };

    final uri = Uri.https(
      googleApiUrl,
      "/maps/api/place/autocomplete/json",
      queryParams,
    );

    /*print("--------");
    print("URI");
    print(uri);*/

    final response = await _http.post(uri);

    final decodedJson = await json.decode(response.body);

    print(decodedJson);

    List places = [];

    if (decodedJson["predictions"].isNotEmpty) {
      int numResults = decodedJson["predictions"].length;

      for (int i = 0; i < numResults; i++) {
        if (decodedJson["predictions"].length > i) {
          places.add(decodedJson["predictions"][i]);
        }
      }
    }

    return places;
  }

  Future<List> getStreets(String pattern, String lang) async {
    final queryParams = {
      "input": pattern,
      "language": lang,
      "types": "address",
      "key": key,
      "sessionToken": getRandomString(10),
    };

    final uri = Uri.https(
      googleApiUrl,
      "/maps/api/place/autocomplete/json",
      queryParams,
    );

    /*print("--------");
    print("URI");
    print(uri);*/

    final response = await _http.post(uri);

    final decodedJson = await json.decode(response.body);

    print(decodedJson);

    List places = [];

    if (decodedJson["predictions"].isNotEmpty) {
      int numResults = decodedJson["predictions"].length;

      for (int i = 0; i < numResults; i++) {
        if (decodedJson["predictions"].length > i) {
          places.add(decodedJson["predictions"][i]);
        }
      }
    }

    return places;
  }

  Future<Map> getInfoPlaceById(String placeId) async {
    Map info = {};

    final queryParams = {
      "place_id": placeId,
      "key": key,
      "sessionToken": getRandomString(10),
    };

    final uri =
        Uri.https(googleApiUrl, "/maps/api/place/details/json", queryParams);

    /*print("--------");
    print("URI");
    print(uri);*/

    final response = await _http.post(uri);

    final decodedJson = await json.decode(response.body);

    print(decodedJson);

    Map placeInfo = decodedJson["result"];

    info.putIfAbsent(
        "lat", () => placeInfo["geometry"]["location"]["lat"].toString());
    info.putIfAbsent(
        "long", () => placeInfo["geometry"]["location"]["lng"].toString());

    String street = "";

    placeInfo["address_components"].forEach((value) {
      if (value["types"].contains("street_number")) {
        street = street + value["long_name"];
      }

      if (value["types"].contains("route")) {
        street = value["long_name"] + street;
      }

      if (value["types"].contains("locality")) {
        info.putIfAbsent("city", () => value["long_name"]);
      }
    });

    info.putIfAbsent("street", () => street);

    return info;
  }

  Future<Map> getInfoPlaceByGeo(double lat, double long) async {
    Map info = {};

    final queryParams = {
      "latlng": "$lat, $long",
      "key": key,
    };

    final uri = Uri.https(googleApiUrl, "/maps/api/geocode/json", queryParams);

    /*print("--------");
    print("URI");
    print(uri);*/

    final response = await _http.post(uri);

    final decodedJson = await json.decode(response.body);

    /*print(decodedJson);*/

    Map placeInfo = decodedJson["results"].first;

    String number = "";
    String route = "";

    placeInfo["address_components"].forEach((value) {
      if (value["types"].contains("street_number")) {
        number = value["long_name"];
      }

      if (value["types"].contains("route")) {
        route = value["long_name"];
      }

      if (value["types"].contains("locality")) {
        info.putIfAbsent("city", () => value["long_name"]);
      }
    });

    String street = "$route${number.isNotEmpty ? ", " + number : ""}";

    info.putIfAbsent("street", () => street);

    return info;
  }

  Future<void> openMap(double latitude, double longitude) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    /*print("URL: $googleUrl");*/
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

import 'dart:convert';

import 'package:app/src/api/api_client.dart';
import 'package:app/src/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static void saveSharedUser(AppUser user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('user', json.encode(user.toJson()));
  }

  static Future<AppUser> getSharedUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      AppUser appUser = AppUser.fromJson(json.decode(prefs.getString('user')));

      return appUser;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future editSharedUser(AppUser user) async {
    removeSharedUser();

    saveSharedUser(user);

    return true;
  }

  static void removeSharedUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final comRead = prefs.getString('communiques');
    prefs.clear();
    await prefs.setString('communiques',comRead);
  }
}

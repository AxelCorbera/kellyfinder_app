import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/globals.dart' as globals;
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/model/municipality/municipality.dart';
import 'package:app/src/model/user.dart';
import 'package:app/src/provider/socket_notifier.dart';
import 'package:app/src/utils/cache/preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserNotifier extends ChangeNotifier {
  AppUser _appUser;

  AppUser get appUser => _appUser;

  User get user => _appUser.user;

  Future<User> initUser(AppUser initUser) async {
    _appUser = initUser;

    globals.accessToken = _appUser.accessToken;

    return _appUser.user;
  }

  void editUser(User editedUser) async {
    _appUser.user = editedUser;

    await Preferences.editSharedUser(_appUser);
    notifyListeners();
  }

  void setUserMunicipality(Municipality municipality) async {
    _appUser.municipality = municipality;

    await Preferences.editSharedUser(_appUser);
    notifyListeners();
  }

  void exitUser(BuildContext context) {
    Provider.of<SocketNotifier>(context, listen: false)
        .disconnectSocket(user.id);

    _appUser = null;
    globals.accessToken = null;

    Preferences.removeSharedUser();

    notifyListeners();
  }

  void getCards() async {
    try {
      var result = await _getMyCards("demand");

      _appUser.demands =
          result['data'].map<Demand>((it) => Demand.fromJson(it)).toList();

      result = await _getMyCards("offer");

      _appUser.offers =
          result['data'].map<Offer>((it) => Offer.fromJson(it)).toList();

      result = await _getMyCards("advertising");

      _appUser.companies =
          result['data'].map<Company>((it) => Company.fromJson(it)).toList();

      Preferences.saveSharedUser(_appUser);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future _getMyCards(String type) async {
    try {
      final result = await ApiProvider().performGetMyCards({"type": type});

      return result;
    } catch (e) {
      throw (e);
    }
  }

  void saveCard(Archive archive) async {
    if (archive is Offer) {
      int temp = _appUser.offers.indexWhere(
        (element) => element.id == archive.id,
      );

      if (temp != -1)
        _appUser.offers[temp] = archive;
      else
        appUser.offers.add(archive);
    } else if (archive is Demand) {
      int temp = _appUser.demands.indexWhere(
        (element) => element.id == archive.id,
      );

      if (temp != -1)
        _appUser.demands[temp] = archive;
      else
        appUser.demands.add(archive);
    } else if (archive is Company) {
      int temp = _appUser.companies.indexWhere(
        (element) => element.id == archive.id,
      );

      if (temp != -1)
        _appUser.companies[temp] = archive;
      else
        appUser.companies.add(archive);
    }

    await Preferences.editSharedUser(_appUser);
    notifyListeners();
  }

  void deleteCard(Archive archive) async {
    if (archive is Offer) {
      int temp =
          _appUser.offers.indexWhere((element) => element.id == archive.id);

      _appUser.offers.removeAt(temp);
    } else if (archive is Demand) {
      int temp =
          _appUser.demands.indexWhere((element) => element.id == archive.id);

      _appUser.demands.removeAt(temp);
    } else if (archive is Company) {
      int temp =
          _appUser.companies.indexWhere((element) => element.id == archive.id);
      _appUser.companies.removeAt(temp);
    }

    await Preferences.editSharedUser(_appUser);
    notifyListeners();
  }

  void initUserSocket(BuildContext context) {
    Provider.of<SocketNotifier>(context, listen: false)
        .initSocket(_appUser.user.id);
  }
}

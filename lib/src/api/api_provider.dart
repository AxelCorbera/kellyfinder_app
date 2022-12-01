import 'dart:developer';
import 'dart:io';

import 'package:app/src/api/api_client.dart';
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/model/category.dart';
import 'package:app/src/model/chat/chat.dart';
import 'package:app/src/model/event.dart';
import 'package:app/src/model/get_child.dart';
import 'package:app/src/model/industrial_park/industrial_park.dart';
import 'package:app/src/model/industrial_park/industrial_park_category.dart';
import 'package:app/src/model/municipality/communique.dart';
import 'package:app/src/model/municipality/image.dart';
import 'package:app/src/model/municipality/municipality.dart';
import 'package:app/src/model/municipality/recommended_visit.dart';
import 'package:app/src/model/municipality/service.dart';
import 'package:app/src/model/user.dart';
import 'package:app/src/model/user/municipal_info.dart';

class ApiProvider {
  static final _provider = ApiProvider._internal();

  ApiProvider._internal();

  factory ApiProvider() => _provider;

  final _apiClient = ApiClient();

  Future<bool> test(Map params) async {
    return _apiClient.test(params);
  }

  Future<GetChild> comprobarNumCards(Map params) async {
    return _apiClient.comprobarNumCards(params);
  }
  Future<GetChild> comprobarNumCardsPoligonos(Map params) async {
    return _apiClient.comprobarNumCardsPoligonos(params);
  }

  Future<AppUser> performSignIn(Map params) async {
    return _apiClient.performSignIn(params);
  }

  Future<AppUser> performSignUp(Map params) async {
    return _apiClient.performSignUp(params);
  }

  Future<String> performNumLotery(String id) async {
    return _apiClient.performNumLotery(id);
  }

  Future<String> performCheckLotery(String id) async {
    return _apiClient.performCheckLotery(id);
  }

  Future<String> performGetEmailSettings() async {
    return _apiClient.performGetEmailSettings();
  }

  Future<bool> performForgot(Map params) async {
    return _apiClient.performForgot(params);
  }

  Future<User> performSetLocation(Map params) async {
    return _apiClient.performSetLocation(params);
  }

  Future<List<Category>> performGetCategories(Map params) async {
    return _apiClient.performGetCategories(params);
  }

  Future<List<Category>> performGetSubcategories(Map params) async {
    return _apiClient.performGetSubcategories(params);
  }

  Future<List<Archive>> performGetByParams(Map params) async {
    return _apiClient.performGetByParams(params);
  }

  Future performRequestCard(Map params) async {
    return _apiClient.performRequestCard(params);
  }

  Future<Offer> performCreateOffer(List images, var video, Map params) async {
    return _apiClient.performCreateOffer(images, video, params);
  }

  Future<Demand> performCreateDemand(List images, var video, Map params) async {
    return _apiClient.performCreateDemand(images, video, params);
  }

  Future<Company> performCreateCompany(
      List images, var video, Map params) async {
    return _apiClient.performCreateCompany(images, video, params);
  }

  Future performGetFavCards(Map params) async {
    return _apiClient.performGetFavCards(params);
  }

  Future<User> performEditProfile(Map params, File file) async {
    return _apiClient.performEditProfile(params, file);
  }

  Future<List<User>> performGetBlockedUsers(Map params) async {
    return _apiClient.performGetBlockedUsers(params);
  }

  Future performUnblock(Map params) async {
    return _apiClient.performUnblock(params);
  }

  Future performBlock(Map params) async {
    return _apiClient.performBlock(params);
  }

  Future<bool> hasBlocked(Map params) async {
    return _apiClient.hasBlocked(params);
  }

  Future performGetChats(Map params) async {
    return _apiClient.performGetChats(params);
  }

  Future performGetMessages(Map params) async {
    return _apiClient.performGetMessages(params);
  }

  Future performSendMessage(Map params) async {
    return _apiClient.performSendMessage(params);
  }

  Future performMarkCardAsFavorite(Map params) async {
    return _apiClient.performMarkCardAsFavorite(params);
  }

  Future performUnMarkCardAsFavorite(Map params) async {
    return _apiClient.performUnMarkCardAsFavorite(params);
  }

  Future performCardReport(Map params) async {
    return _apiClient.performCardReport(params);
  }

  Future performCloseSession(Map params) async {
    return _apiClient.performCloseSession(params);
  }

  Future performRemoveAccount(Map params) async {
    return _apiClient.performRemoveAccount(params);
  }

  Future performGetMyCard(Map params) async {
    return _apiClient.performGetMyCard(params);
  }

  Future performGetMyCards(Map params) async {
    return _apiClient.performGetMyCards(params);
  }

  Future performDeleteCard(Map params) async {
    return _apiClient.performDeleteCard(params);
  }

  Future performDeleteRequestCard(Map params) async {
    return _apiClient.performDeleteRequestCard(params);
  }

  Future performGetPetitions(Map params) async {
    return _apiClient.performGetPetitions(params);
  }

  Future performDeleteRoom(Map params) async {
    return _apiClient.performDeleteRoom(params);
  }

  Future performAcceptCard(Map params) async {
    return _apiClient.performAcceptCard(params);
  }

  Future performRefuseCard(Map params) async {
    return _apiClient.performRefuseCard(params);
  }

  Future<Chat> performCreateRoom(Map params) async {
    return _apiClient.performCreateRoom(params);
  }

  Future performHasNewNotifications(Map params) async {
    return _apiClient.performHasNewNotifications(params);
  }

  Future performHasEnoughCards(Map params) async {
    return _apiClient.performHasEnoughCards(params);
  }

  Future performGetByType(Map params) async {
    return _apiClient.performGetByType(params);
  }

  Future performIsLotteryActive(Map params) async {
    return _apiClient.performIsLotteryActive(params);
  }

  Future performGetCommunities(Map params) async {
    return _apiClient.performGetCommunities(params);
  }

  Future performGetProvinces(Map params) async {
    return _apiClient.performGetProvinces(params);
  }

  Future performGetMunicipalities(Map params) async {
    return _apiClient.performGetMunicipalities(params);
  }

  Future requestCustomCode(Map params) async {
    return _apiClient.requestCustomCode(params);
  }

  Future sendCodeEmail(Map params) async {
    return _apiClient.sendCodeEmail(params);
  }

  Future validateCode(Map params) async {
    return _apiClient.validateCode(params);
  }

  Future requestCode(Map params) async {
    return _apiClient.requestCode(params);
  }

  Future createMunicipality(Map params, List images, var video) async {
    return _apiClient.createMunicipality(params, images, video);
  }

  Future<List<MunicipalityImage>> getMunicipalityPics(Map params, int municipalityId) async {
    return _apiClient.getMunicipalityPics(params, municipalityId);
  }

  Future createMunicipalityPic(Map params, List images, int municipalityId) async {
    return _apiClient.createMunicipalityPic(params, images, municipalityId);
  }

  Future deleteMunicipalityPic(Map params, int picId) async {
    return _apiClient.deleteMunicipalityPic(params, picId);
  }

  Future<RecommendedVisit> createRecommendedVisit(Map params, int municipalityId) async {
    return _apiClient.createRecommendedVisit(params, municipalityId);
  }

  Future<List<RecommendedVisit>> getRecommendedVisits(Map params, int municipalityId) async {
    return _apiClient.getRecommendedVisits(params, municipalityId);
  }

  Future deleteRecommendedVisit(Map params, int recommendedVisitId) async {
    return _apiClient.deleteRecommendedVisit(params, recommendedVisitId);
  }

  Future<List<Event>> getEvents(Map params, int municipalityId) async {
    return _apiClient.getEvents(params, municipalityId);
  }

  Future<Event> createEvent(Map params, int municipalityId) async {
    return _apiClient.createEvent(params, municipalityId);
  }

  Future deleteEvent(Map params, int eventId) async {
    return _apiClient.deleteEvent(params, eventId);
  }

  Future<List<Municipality>> getMunicipalitiesByDistance(Map params) async {
    return _apiClient.getMunicipalitiesByDistance(params);
  }

  Future<Municipality> getMunicipalitiesByUbication(Map params) async {
    return _apiClient.getMunicipalitiesByUbication(params);
  }

  Future<List<Service>> getMunicipalityServices(Map params) async {
    return _apiClient.getMunicipalityServices(params);
  }

  Future<List<Communique>> getCommuniques(Map params, int municipalityId) async {
    return _apiClient.getCommuniques(params, municipalityId);
  }

  Future<MunicipalInfo> getMunicipalInfo(Map params) async {
    return _apiClient.getMunicipalInfo(params);
  }

  Future<MunicipalInfo> editMunicipalInfo(Map params) async {
    return _apiClient.editMunicipalInfo(params);
  }

  Future isMunicipalitySelected(Map params) async {
    return _apiClient.isMunicipalitySelected(params);
  }

  Future deleteCommunique(Map params, int newId) async {
    return _apiClient.deleteCommunique(params, newId);
  }

  Future hideCommunique(Map params, int newId) async {
    return _apiClient.hideCommunique(params, newId);
  }

  Future createCommunique(Map params, int municipalityId, var media, String type) async {
    return _apiClient.createCommunique(params, municipalityId, media, type);
  }

  Future setDeviceInfo(Map params) async {
    return _apiClient.setDeviceInfo(params);
  }

  Future<List<IndustrialPark>> getIndustrialParks(Map params) async {
    return _apiClient.getIndustrialParks(params);
  }

  Future<List<IndustrialParkCategory>> getIndustrialParkCategories(Map params) async {
    return _apiClient.getIndustrialParkCategories(params);
  }

  Future<List<Company>> getIndustrialParkCompanies(Map params) async {
    return _apiClient.getIndustrialParkCompanies(params);
  }

  Future<List<Company>> getMunicipalityCompanies(Map params) async {
    return _apiClient.getMunicipalityCompanies(params);
  }
}

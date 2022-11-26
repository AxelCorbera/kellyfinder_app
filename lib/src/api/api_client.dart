import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/globals.dart' as globals;
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
import 'package:app/src/ui/screens/sign_in/sign_in_screen.dart';
import 'package:app/src/utils/api/api_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';

const String NOT_IMPLEMENTED = "";

class ApiClient {
  static final _client = ApiClient._internal();
  final _http = http.Client();

  ApiClient._internal();

  //final baseUrl = "http://127.0.0.1";
  final baseUrl = "stage.kellyfindermail.com";
  final currentVersion = "/api";

  factory ApiClient() => _client;

  Future<bool> test(Map params) async {
    final result = await _performRequest(params, "card/test", isPost: false);

    return result["data"];
  }

  Future<GetChild> comprobarNumCards(Map params) async {
    final queryParams = {"data": json.encode(params)};

    final uri = Uri.http('dev.kellyfindermail.com',
        "kellyfinder_back/public/categorias/comprobar_num_cards.php", params);
    log(uri.query);
    //printWrapped(globals.accessToken);

    http.Response response;

    // if (isPost) {
    //   if (header)
    //     response = await _http.post(uri,
    //         headers: {HttpHeaders.authorizationHeader: globals.accessToken});
    //   else
    //     response = await _http.post(uri);
    // } else {
    //  if (header)
        response = await _http.get(uri,
            headers: {HttpHeaders.authorizationHeader: globals.accessToken});
    //   else
    //     response = await _http.get(uri);
    // }

    //final result = await _performRequest(params, "categorias/comprobar_num_cards", isPost: false);
    log(response.body);
    GetChild getChild = GetChild.fromJson(json.decode(response.body));
    return getChild;
  }

  Future<GetChild> comprobarNumCardsPoligonos(Map params) async {
    final queryParams = {"data": json.encode(params)};

    final uri = Uri.http('dev.kellyfindermail.com',
        "kellyfinder_back/public/categorias/comprobar_num_cards_poligonos.php", params);
    log(uri.query);
    //printWrapped(globals.accessToken);

    http.Response response;

    response = await _http.get(uri,
    headers: {HttpHeaders.authorizationHeader: globals.accessToken});

    log(response.body);
    GetChild getChild = GetChild.fromJson(json.decode(response.body));
    return getChild;
  }

  Future<AppUser> performSignIn(Map params) async {
    final result = await _performRequest(params, "user/login", header: false);

    return AppUser.fromJson(result['data']);
  }

  Future<AppUser> performSignUp(Map params) async {
    final result =
        await _performRequest(params, "user/register", header: false);

    return AppUser.fromJson(result['data']);
  }

  Future<bool> performForgot(Map params) async {
    await _performRequest(params, "user/forget", header: false);

    return true;
  }

  Future<String> performNumLotery(String id) async{

    final uri = Uri.http('dev.kellyfindermail.com',
        "kellyfinder_back/public/categorias/asignar_num_loteria_usuario.php",
        {
          "id_usuario": id,
        });
    log(uri.query);

    http.Response response;

    response = await _http.get(uri,
        headers: {HttpHeaders.authorizationHeader: globals.accessToken});

    //log(response.body);
    return response.body.toString();
  }

  Future<User> performSetLocation(Map params) async {
    final result = await _performRequest(params, "user/setLocation");

    return User.fromJson(result['data']);
  }

  Future<List<Category>> performGetCategories(Map params) async {
    final result =
        await _performRequest(params, "category/getAll", isPost: false);

    //print(result["data"].last);

    return result['data'].map<Category>((it) => Category.fromJson(it)).toList();
  }

  Future<List<Category>> performGetSubcategories(Map params) async {
    final result = await _performRequest(params, "category/getSubcategories",
        isPost: false);

    return result['data'].map<Category>((it) => Category.fromJson(it)).toList();
  }

  Future<List<Archive>> performGetByParams(Map params) async {
    final result =
        await _performRequest(params, "card/getByParams", isPost: false);

    if (params["type"] == "demand") {
      return result['data'].map<Demand>((it) => Demand.fromJson(it)).toList();
    } else if (params["type"] == "offer") {
      return result['data'].map<Offer>((it) => Offer.fromJson(it)).toList();
    } else {
      return result['data'].map<Company>((it) => Company.fromJson(it)).toList();
    }
  }

  Future performRequestCard(Map params) async {
    final result = await _performRequest(params, "user/sendRequestCard");

    return result["data"];
  }

  Future<Offer> performCreateOffer(List images, var video, Map params) async {
    final result =
        await _performMedia(params, "card/createOffer", images, video: video);

    return Offer.fromJson(result["data"]);
  }

  Future<Demand> performCreateDemand(List images, var video, Map params) async {
    final result =
        await _performMedia(params, "card/createDemand", images, video: video);

    return Demand.fromJson(result["data"]);
  }

  Future<Company> performCreateCompany(
      List images, var video, Map params) async {
    final result = await _performMedia(params, "card/createAdvertising", images,
        video: video);

    return Company.fromJson(result["data"]);
  }

  Future performGetFavCards(Map params) async {
    final result =
        await _performRequest(params, "user/getFavoriteCards", isPost: false);

    return result;
  }

  Future<User> performEditProfile(Map params, File file) async {
    List<File> files = [];

    if (file != null) files.add(file);

    final result =
        await _performMedia(params, "user/edit", files, isArray: false);

    return User.fromJson(result["data"]);
  }

  Future<List<User>> performGetBlockedUsers(Map params) async {
    final result =
        await _performRequest(params, "user/getBlockedUsers", isPost: false);

    return result['data']
        .map<User>((it) => User.fromJson(it["blocked_user"]))
        .toList();
  }

  Future performUnblock(Map params) async {
    await _performRequest(params, "user/unblockUser");

    return true;
  }

  Future performBlock(Map params) async {
    await _performRequest(params, "user/blockUser");

    return true;
  }

  Future<bool> hasBlocked(Map params) async {
    final result = await _performRequest(params, "user/has-blocked", isPost: false);

    return result["data"];
  }

  Future performGetChats(Map params) async {
    final result =
        await _performRequest(params, "chat/getRooms", isPost: false);

    return result["data"];
  }

  Future performGetMessages(Map params) async {
    final result =
        await _performRequest(params, "chat/getMessages", isPost: false);

    return result["data"];
  }

  Future performSendMessage(Map params) async {
    final result =
        await _performRequest(params, "chat/sendMessage", isPost: false);

    return result["data"];
  }

  Future performMarkCardAsFavorite(Map params) async {
    final result = await _performRequest(params, "user/markCardAsFavorite");

    return result["data"];
  }

  Future performUnMarkCardAsFavorite(Map params) async {
    final result = await _performRequest(params, "user/unmarkCardAsFavorite");

    return result["data"];
  }

  Future performCardReport(Map params) async {
    final result = await _performRequest(params, "user/reportCard");

    return result["data"];
  }

  Future performCloseSession(Map params) async {
    final result = await _performRequest(params, "user/logout", isPost: false);

    return result["data"];
  }

  Future performRemoveAccount(Map params) async {
    final result = await _performRequest(params, "user/delete");

    return result["data"];
  }

  Future performGetMyCard(Map params) async {
    final result =
        await _performRequest(params, "card/getMyCard", isPost: false);

    return result["data"];
  }

  Future performGetMyCards(Map params) async {
    final result =
        await _performRequest(params, "card/getMyCards", isPost: false);

    return result;
  }

  Future performDeleteCard(Map params) async {
    final result = await _performRequest(params, "card/delete");

    return result["data"];
  }

  Future performDeleteRequestCard(Map params) async {
    final result = await _performRequest(params, "user/deleteRequestCard");

    return result["data"];
  }

  Future performGetPetitions(Map params) async {
    final result = await _performRequest(params, "user/getRequests");

    return result["data"];
  }

  Future performDeleteRoom(Map params) async {
    await _performRequest(params, "chat/deleteRoom");

    return true;
  }

  Future performAcceptCard(Map params) async {
    final result = await _performRequest(params, "user/acceptRequestCard");

    return result["data"];
  }

  Future performRefuseCard(Map params) async {
    final result = await _performRequest(params, "user/closeRequestCard");

    return result["data"];
  }

  Future<Chat> performCreateRoom(Map params) async {
    final result = await _performRequest(params, "chat/setRoom");

    return Chat.fromJson(result["data"]);
  }

  Future performHasNewNotifications(Map params) async {
    final result = await _performRequest(params, "user/hasNewNotifications");

    return result["data"];
  }

  Future performHasEnoughCards(Map params) async {
    final result =
        await _performRequest(params, "ama/hasEnoughCards", isPost: false);

    return result["data"];
  }

  Future performGetByType(Map params) async {
    final result =
        await _performRequest(params, "category/getByType", isPost: false);

    return result["data"];
  }

  Future performIsLotteryActive(Map params) async {
    final result = await _performRequest(params, "ama/isLotteryActive",
        isPost: false, header: false);

    //print(result);

    return result["data"];
  }

  Future performGetCommunities(Map params) async {
    final result =
        await _performRequest(params, /*"town/getComunidades"*/"communities", isPost: false);

    return result["data"];
  }

  Future performGetProvinces(Map params) async {
    final result =
        await _performRequest(params, /*"town/getProvincias"*/"provinces", isPost: false);

    return result["data"];
  }

  Future performGetMunicipalities(Map params) async {
    final result =
        await _performRequest(params, "municipalities", isPost: false);

    return result["data"];
  }

  Future requestCustomCode(Map params) async {
    final result = await _performRequest(params, "municipalities/code/request/custom");

    return result["data"];
  }

  Future sendCodeEmail(Map params) async {
    final result = await _performRequest(params, NOT_IMPLEMENTED);

    return result["data"];
  }

  Future validateCode(Map params) async {
    final result = await _performRequest(params, "municipalities/code/validate");

    return result["data"];
  }

  Future requestCode(Map params) async {
    final result = await _performRequest(params, "municipalities/code/request", header: true);

    return result["data"];
  }

  Future createMunicipality(Map params, List images, var video) async {
    final result = await _performMedia(params, "municipalities/create", images, video: video);

    return result["data"];
  }

  Future<List<MunicipalityImage>> getMunicipalityPics(Map params, int municipalityId) async {
    final result =
    await _performRequest(params, "municipalities/pics/$municipalityId", isPost: false);

    return result['data'].map<MunicipalityImage>((it) => MunicipalityImage.fromJson(it)).toList();
  }

  Future createMunicipalityPic(Map params, List<dynamic> images, int municipalityId) async {
    final result = await _performMedia(params, "municipalities/pics/$municipalityId", images, video: null);
    return result["data"];
  }

  Future deleteMunicipalityPic(Map params, int picId) async {
    final result = await _performRequest(params, "municipalities/pics/$picId/delete", header: true);
    return result["data"];
  }

  Future<RecommendedVisit> createRecommendedVisit(Map params, int municipalityId) async {
    final result = await _performRequest(params, "municipalities/best-places/$municipalityId", header: true);
    return RecommendedVisit.fromJson(result["data"]);
  }

  Future<List<RecommendedVisit>> getRecommendedVisits(Map params, int municipalityId) async {
    final result =
    await _performRequest(params, "municipalities/best-places/$municipalityId", isPost: false);

    return result['data'].map<RecommendedVisit>((it) => RecommendedVisit.fromJson(it)).toList();
  }

  Future deleteRecommendedVisit(Map params, int recommendedVisitId) async {
    final result = await _performRequest(params, "municipalities/best-places/$recommendedVisitId/delete", header: true);
    return result["data"];
  }

  Future<List<Event>> getEvents(Map params, int municipalityId) async {
    final result =
    await _performRequest(params, "municipalities/calendar/$municipalityId", isPost: false);

    return result['data'].map<Event>((it) => Event.fromJson(it)).toList();
  }

  Future<Event> createEvent(Map params, int municipalityId) async {
    final result = await _performRequest(params, "municipalities/calendar/$municipalityId", header: true);
    return Event.fromJson(result["data"]);
  }

  Future deleteEvent(Map params, int eventId) async {
    final result = await _performRequest(params, "municipalities/calendar/$eventId/delete", header: true);
    return result["data"];
  }

  Future<List<Municipality>> getMunicipalitiesByDistance(Map params) async {
    final result =
    await _performRequest(params, "municipalities/by-distance", isPost: false);

    return result['data']['data'].map<Municipality>((it) => Municipality.fromJson(it)).toList();
  }

  Future<Municipality> getMunicipalitiesByUbication(Map params) async {
    log(params.toString());
    final result =
    await _performRequest(params, "municipalities/by-ubication", isPost: false);
    log(params.toString());
    log(result.toString());
    return Municipality.fromJson(result['data']);
  }

  Future<List<Service>> getMunicipalityServices(Map params) async {
    final result =
    await _performRequest(params, "card/categories/advertising", isPost: false);

    return result['data'].map<Service>((it) => Service.fromJson(it)).toList();
  }

  Future<List<Communique>> getCommuniques(Map params, int municipalityId) async {
    final result =
        await _performRequest(params, "municipalities/news/$municipalityId", isPost: false);

    return result['data'].map<Communique>((it) => Communique.fromJson(it)).toList();
  }

  Future<MunicipalInfo> getMunicipalInfo(Map params) async {
    final result =
    await _performRequest(params, "user/municipal-information/", isPost: false);

    return MunicipalInfo.fromJson(result['data']);
  }

  Future<MunicipalInfo> editMunicipalInfo(Map params) async {
    final result =
    await _performRequest(params, "user/municipal-information/edit");

    return MunicipalInfo.fromJson(result['data']);
  }

  Future isMunicipalitySelected(Map params) async {
    final result =
    await _performRequest(params, "user/municipal-information/is-municipality-selected/", isPost: false);

    return result['data'];
  }

  Future deleteCommunique(Map params, int newId) async {
    final result =
        await _performRequest(params, "municipalities/news/$newId/delete");

    return result["data"];
  }

  Future hideCommunique(Map params, int newId) async {
    final result =
    await _performRequest(params, "municipalities/news/$newId/hide");

    return result["data"];
  }

  Future createCommunique(Map params, int municipalityId, var media, String type) async {
    final result = await _performMediaCommunique(params, "municipalities/news/$municipalityId", media, type);

    return result["data"];
  }

  Future setDeviceInfo(Map params) async {
    final result = await _performRequest(params, NOT_IMPLEMENTED);

    return result["data"];
  }

  Future<List<IndustrialPark>> getIndustrialParks(Map params) async {
    final result =
    await _performRequest(params, "industrial-parks", isPost: false);

    return result['data']['data'].map<IndustrialPark>((it) => IndustrialPark.fromJson(it)).toList();
  }

  Future<List<IndustrialParkCategory>> getIndustrialParkCategories(Map params) async {
    final result =
    await _performRequest(params, "industrial-parks/categories", isPost: false);

    return result['data'].map<IndustrialParkCategory>((it) => IndustrialParkCategory.fromJson(it)).toList();
  }

  Future<List<Company>> getIndustrialParkCompanies(Map params) async {
    final result =
    await _performRequest(params, "industrial-parks/enterprises", isPost: false);

    return result['data'].map<Company>((it) => Company.fromJson(it)).toList();
  }

  Future<List<Company>> getMunicipalityCompanies(Map params) async {
    final result =
    await _performRequest(params, "card/by-category", isPost: false);

    return result['data'].map<Company>((it) => Company.fromJson(it)).toList();
  }

  Future<Map> _performRequest(Map params, String route,
      {bool header = true, bool isPost = true}) async {
     int page;

    if (params.containsKey("page")) {
      page = params["page"];

      params.remove("page");
    }

    final queryParams = {"data": json.encode(params)};

    if (page != null) queryParams.putIfAbsent("page", () => "$page");

    final uri = Uri.http(baseUrl, "$currentVersion/$route", queryParams);

    //print(uri);
    //printWrapped(globals.accessToken);

    http.Response response;

    if (isPost) {
      if (header)
        response = await _http.post(uri,
            headers: {HttpHeaders.authorizationHeader: globals.accessToken});
      else
        response = await _http.post(uri);
    } else {
      if (header)
        response = await _http.get(uri,
            headers: {HttpHeaders.authorizationHeader: globals.accessToken});
      else
        response = await _http.get(uri);
    }

    //log(response.body.toString());

    return await _decodeResponse(response.body);
  }

  Future<Map> _performMedia(Map params, String route, List media,
      {var video, bool isArray = true}) async {
    final queryParams = {"data": json.encode(params)};

    final uri = Uri.http(baseUrl, "$currentVersion/$route", queryParams);

    print(uri);

    FormData formData;

    if (media.isNotEmpty) {
      List<MultipartFile> multipartImages = [];

      for (int i = 0; i < media.length; i++) {
        File tempFile;

        if (media[i] is String) {
          tempFile = await _urlToFile(media[i]);
        } else {
          tempFile = media[i];
        }

        MultipartFile multipartFile = await MultipartFile.fromFile(
          tempFile.path,
          filename: "image$i.png",
          contentType: MediaType('image', 'jpeg'),
        );

        multipartImages.add(multipartFile);
      }

      if (!isArray) {
        formData = new FormData.fromMap({
          "media": multipartImages.first,
        });
      } else {
        formData = new FormData.fromMap({
          "media": multipartImages,
        });
      }
    }

    if (video != null && video is File) {
      if(formData == null){
        formData = new FormData.fromMap({});
      }

      MultipartFile multipartFile = await MultipartFile.fromFile(
        video.path,
        filename: "video.mp4",
        contentType: MediaType('video', 'mp4'),
      );

      MultipartFile multipartVideo = multipartFile;

      formData.files.add(MapEntry("video", multipartVideo));
    }

    Dio dio = new Dio();

    Response response = await dio.post(
      uri.toString(),
      data: formData,
      options: Options(
        headers: {HttpHeaders.authorizationHeader: globals.accessToken},
      ),
    );

    print("data");
    printWrapped(response.data.toString());
    return response.data;
  }

  Future<Map> _performMediaCommunique(Map params, String route, var media, String type) async {
    final queryParams = {"data": json.encode(params)};

    final uri = Uri.http(baseUrl, "$currentVersion/$route", queryParams);

    print(uri);

    FormData formData;

    if (media != null) {
      MultipartFile multipartFile;

      /*File tempFile;
      tempFile = media;*/

      if(type == "image"){
        multipartFile = await MultipartFile.fromFile(
          media.path,
          filename: "image.png",
          contentType: MediaType('image', 'jpeg'),
        );
      }else if(type == "text"){

      }else if(type == "audio"){
        print("ES AUDIO");
        multipartFile = await MultipartFile.fromFile(
          media.path,
          filename: "audio.wav",
          contentType: MediaType('audio', 'wav'),
        );
      }else if(type == "video"){
        multipartFile = await MultipartFile.fromFile(
          media.path,
          filename: "video.mp4",
          contentType: MediaType('video', 'mp4'),
        );
      }

      /*if (media is String) {
        tempFile = await _urlToFile(media);
      } else {
        tempFile = media;
      }*/

      formData = new FormData.fromMap({
        "media": multipartFile,
      });
    }else{
      formData = new FormData.fromMap({
        "media": null,
      });
    }

    Dio dio = new Dio();

    Response response = await dio.post(
      uri.toString(),
      data: formData,
      options: Options(
        headers: {HttpHeaders.authorizationHeader: globals.accessToken},
      ),
    );

    print("data");
    //printWrapped(response.data.toString());
    return response.data;
  }

  Future<Map> _decodeResponse(response) async {
    Map result = await json.decode(response);

    printWrapped(result.toString());

    BuildContext context = globals.navigatorKey.currentContext;

    if (result["rc"] == 0) {
      return result;
    } else if (result["rc"] == 2202) {
      throw ApiException(
        AppLocalizations.of(context).translate("errorEmail"),
        result["rc"],
      );
    } else if (result["rc"] == 2001) {
      throw ApiException(
        AppLocalizations.of(context).translate("errorLogin"),
        result["rc"],
      );
    } else if (result["rc"] == 2401) {
      throw ApiException(
        AppLocalizations.of(context).translate("signup_raffle_code_error"),
        result["rc"],
      );
    } else if(result["rc"] == 32000){
      throw ApiException(
        AppLocalizations.of(context).translate("municipality_validate_code_not_valid_error"),
        result["rc"],
      );
    } else if(result["rc"] == 32001){
      throw ApiException(
        AppLocalizations.of(context).translate("municipality_validate_code_no_longer_valid"),
        result["rc"],
      );
    } else if(result["rc"] == 32002){
      throw ApiException(
        AppLocalizations.of(context).translate("municipality_request_code_already_requested_error"),
        result["rc"],
      );
    } else if (result["rc"] == 666) {
      //CADUCA EL TOKEN
      globals.navigatorKey.currentState.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => SignInScreen(),
        ),
        (_) => false,
      );
    }

    throw ApiException(
        AppLocalizations.of(context).translate("errorPetition"), result["rc"]);
  }
}

void printWrapped(String text) {
  final pattern = new RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

Future<File> _urlToFile(String imageUrl) async {
  var rng = new math.Random();
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  File file = new File('$tempPath' + (rng.nextInt(100)).toString() + '.png');
  http.Response response = await http.get(imageUrl);
  await file.writeAsBytes(response.bodyBytes);
  return file;
}

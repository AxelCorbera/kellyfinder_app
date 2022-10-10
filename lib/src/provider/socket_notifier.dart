import 'dart:convert';

import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/globals.dart';
import 'package:app/src/model/petition.dart';
import 'package:app/src/utils/socket/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'chat_notifier.dart';

class SocketNotifier extends ChangeNotifier {
  SocketService _socketService;

  bool _newNotification = false;
  bool _newChat = false;
  List<Petition> _sentPetitions = [];
  List<Petition> _receivedPetitions = [];

  List<Petition> get receivedPetitions => _receivedPetitions;

  List<Petition> get sentPetitions => _sentPetitions;

  bool get newNotification => _newNotification;

  bool get newChat => _newChat;

  @override
  void dispose() {
    //disconnectSocket();

    super.dispose();
  }

  void initSocket(int userId) {
    _socketService = SocketService();

    _socketService.firePusher(
        _getChannelName(userId), "App\\Events\\NotificationEvent");

    _socketService.eventStream.listen(
      (data) {
        print("IN SOCKET");
        print("RESULT: $data");
        final result = json.decode(data);

        addPetition(result);
      },
      onError: (error) {
        print("Error: $error");
      },
      cancelOnError: false,
      onDone: () {
        print("Done");
      },
    );
  }

  void disconnectSocket(int userId) {
    _newNotification = false;
    _newChat = false;
    _sentPetitions = [];
    _receivedPetitions = [];

    _socketService.unSubscribePusher(_getChannelName(userId));

    _socketService = null;
  }

  String _getChannelName(int userId) {
    return 'presence-190.app.$userId';
  }

  void fillPetitions(List<Petition> sent, List<Petition> received) {
    _newNotification = false;

    _sentPetitions = sent;
    _receivedPetitions = received;

    notifyListeners();
  }

  void addPetition(final result) {
    if (result["message"] == "new_request") {
      addNewNotification();
    } else {
      addNewChat(true);

      Provider.of<ChatNotifier>(navigatorKey.currentContext, listen: false)
          .notificationSocketNewMessage(result);
    }
  }

  void addNewNotification() {
    _newNotification = true;
    notifyListeners();
  }

  void addNewChat(bool value) {
    _newChat = value;
    notifyListeners();
  }

  Future removePetition(Petition petition) async {
    try {
      final result = await ApiProvider()
          .performDeleteRequestCard({"request_id": petition.id});

      if (result == 1) {
        _receivedPetitions.remove(petition);
        _sentPetitions.remove(petition);
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }

  Future acceptPetition(Petition petition) async {
    try {
      final result =
          await ApiProvider().performAcceptCard({"request_id": petition.id});

      petition.isActive = result == 1 ? true : false;

      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future refusePetition(Petition petition) async {
    try {
      final result =
          await ApiProvider().performRefuseCard({"request_id": petition.id});

      petition.isActive = result == 1 ? true : false;

      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}

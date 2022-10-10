import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/globals.dart';
import 'package:app/src/model/chat/chat.dart';
import 'package:app/src/model/chat/message.dart';
import 'package:app/src/model/user.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatNotifier extends ChangeNotifier {
  List<Chat> _offerChats;
  List<Chat> _demandChats;

  List<Chat> get offerChats => _offerChats;

  List<Chat> get demandChats => _demandChats;

  Future getUserChats(User user, key) async {
    try {
      final result = await ApiProvider().performGetChats({});

      _offerChats =
          result["offers"].map<Chat>((it) => Chat.fromJson(it)).toList();

      _demandChats =
          result["demands"].map<Chat>((it) => Chat.fromJson(it)).toList();

      return true;
    } catch (e) {
      catchErrors(e, key);
    }
  }

  Future updateUserChats(User user) async {
    try {
      ApiProvider().performGetChats({}).then((result) {
        _offerChats =
            result["offers"].map<Chat>((it) => Chat.fromJson(it)).toList();

        _demandChats =
            result["demands"].map<Chat>((it) => Chat.fromJson(it)).toList();

        notifyListeners();
      });

      return true;
    } catch (e) {
      print(e);
    }
  }

  Future performRemoveChat(Chat chat, key) async {
    try {
      final result =
          await ApiProvider().performDeleteRoom({"room_id": chat.id});

      if (result == true) {
        offerChats.remove(chat);
        demandChats.remove(chat);
        notifyListeners();
      }

      return true;
    } catch (e) {
      catchErrors(e, key);

      return null;
    }
  }

  Future performBlockUser(Chat chat, key) async {
    try {
      final result =
          await ApiProvider().performBlock({"blocked_user": chat.contact.id});

      if (result == true) {
        offerChats.remove(chat);
        demandChats.remove(chat);
        notifyListeners();
      }

      return true;
    } catch (e) {
      catchErrors(e, key);

      return null;
    }
  }

  Future performDeleteMessage(Chat chat) async {
    try {
      bool result;
      //final result = await ApiProvider().performDeleteChat(chat);

      if (result == true) {
        //chats.remove(chat);
      }

      notifyListeners();

      return true;
    } catch (e) {
      print(e);
      return null;
    }
  }

  void setLastMessage(Chat chat, Message lastMessage) {
    chat.lastMessage = lastMessage;
    notifyListeners();
  }

  void notificationSocketNewMessage(final result) {
    updateUserChats(
        Provider.of<UserNotifier>(navigatorKey.currentContext, listen: false)
            .user);
  }
}

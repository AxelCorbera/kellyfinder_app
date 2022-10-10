import 'dart:convert';

import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/sentence_case_text_formatter.dart';
import 'package:app/src/config/string_casing_extension.dart';
import 'package:app/src/model/chat/chat.dart';
import 'package:app/src/model/chat/message_incoming.dart';
import 'package:app/src/model/chat/message_outgoing.dart';
import 'package:app/src/model/user.dart';
import 'package:app/src/provider/chat_notifier.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/widgets/chat/chat_message.dart';
import 'package:app/src/ui/widgets/chat/chat_message_incoming.dart';
import 'package:app/src/ui/widgets/chat/chat_message_outgoing.dart';
import 'package:app/src/ui/widgets/dialog/custom_dialog.dart';
import 'package:app/src/ui/widgets/image/network_profile_image.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/socket/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;

  const ChatScreen({Key key, this.chat}) : super(key: key);

  @override
  State createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  SocketService _socketService;

  Future _futureGetMessages;

  List<ChatMessage> _messages = <ChatMessage>[];
  TextEditingController _textController;

  bool _isComposing = false;

  @override
  void initState() {
    super.initState();

    _socketService = SocketService();

    _textController = new TextEditingController();

    _futureGetMessages = _getMessages();
  }

  void dispose() {
    disconnectSocket();

    for (ChatMessage message in _messages)
      message.animationController.dispose();

    _textController.dispose();

    super.dispose();
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        centerTitle: true,
        title: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            NetworkProfileImage(
              image: widget.chat.contact.image,
              width: 36,
              height: 36,
            ),
            SizedBox(width: 8),
            Expanded(
              child: new Text(
                widget.chat.contact.name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          PopupMenuButton<int>(
            onSelected: (int value) async {
              final result = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  if (value == 1)
                    return CustomDialog(
                      title: AppLocalizations.of(context)
                          .translate("sureBlockUser"),
                      buttonText:
                          AppLocalizations.of(context).translate("block"),
                    );
                  else
                    return CustomDialog(
                      title: AppLocalizations.of(context)
                          .translate("sureDeleteChat"),
                      buttonText:
                          AppLocalizations.of(context).translate("delete"),
                    );
                },
              );

              if (result == true) {
                ChatNotifier chatNotifier =
                    Provider.of<ChatNotifier>(context, listen: false);

                if (value == 1)
                  chatNotifier.performBlockUser(widget.chat, _scaffoldKey);
                else
                  chatNotifier.performRemoveChat(widget.chat, _scaffoldKey);

                Navigator.pop(context);
              }
            },
            offset: Offset(0, 20),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              PopupMenuItem<int>(
                value: 1,
                child: Center(
                    child: Text(
                        AppLocalizations.of(context).translate("blockUser"))),
                height: 32,
              ),
              PopupMenuDivider(),
              PopupMenuItem<int>(
                value: 2,
                child: Center(
                    child: Text(
                  AppLocalizations.of(context).translate("deleteChat"),
                )),
                height: 32,
              ),
            ],
          )
        ],
      ),
      body: new Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          new Expanded(child: _buildFuture()),
          _buildTextComposer(),
        ],
      ),
    );
  }

  Widget _buildFuture() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: FutureBuilder(
        future: _futureGetMessages,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            /*return ListView.builder(
              padding: new EdgeInsets.all(8.0),
              physics: AlwaysScrollableScrollPhysics(),
              reverse: true,
              itemBuilder: (_, int index) => _messages[index],
              itemCount: _messages.length,

            );*/

            return ListView.builder(
              padding: new EdgeInsets.all(8.0),
              physics: AlwaysScrollableScrollPhysics(),
              reverse: true,
              itemBuilder: (_, int index) {
                /*User _user =
                    Provider.of<UserNotifier>(context, listen: false).user;

                if (!_messages[index].message.hasBeenRead &&
                    i == 0 &&
                    _user.id != _messages[index].message.user.id) {
                  i++;

                  return Column(
                    children: <Widget>[
                      Divider(),
                      _messages[index],
                    ],
                  );
                }*/

                return _messages[index];
              },
              itemCount: _messages.length,
            );
          }
          return FutureCircularIndicator();
        },
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Material(
        borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
        color: Colors.transparent,
        elevation: 8,
        child: new TextField(
          inputFormatters: [
            SentenceCaseTextFormatter()
          ],
          maxLines: 6,
          autofocus: false,
          minLines: 1,
          controller: _textController,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.text,
          onSubmitted: _isComposing ? _handleSubmittedText : null,
          onChanged: (String text) {
            setState(() {
              _isComposing = text.length > 0;
            });
          },
          decoration: new InputDecoration(
            hintText: AppLocalizations.of(context).translate("writeMessage"),
            suffixIcon: IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                if (_isComposing) _handleSubmittedText(_textController.text);
              },
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(12),
            border: new OutlineInputBorder(
              borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
              borderSide: BorderSide(width: 0, style: BorderStyle.none),
            ),
          ),
        ),
      ),
    );
  }

  Future _getMessages() async {
    try {
      final result =
          await ApiProvider().performGetMessages({"room_id": widget.chat.id});

      result.forEach((message) {
        addMessage(message);
      });

      if (result.isNotEmpty) {
        Provider.of<ChatNotifier>(context, listen: false)
            .setLastMessage(widget.chat, _messages.first.message);
      }

      return true;
    } catch (e) {
      Navigator.pop(context);

      catchErrors(e, _scaffoldKey);
      return null;
    } finally {
      initSocket();
    }
  }

  Future _handleSubmittedText(String value) async {
    try {
      await ApiProvider().performSendMessage({
        "room_id": widget.chat.id,
        "message": _textController.text,
      });

      _textController.clear();

      _isComposing = false;

      return true;
    } catch (e) {
      //Navigator.pop(context);

      catchErrors(e, _scaffoldKey);
      return null;
    }
  }

  void addMessage(result) {
    User _user = Provider.of<UserNotifier>(context, listen: false).user;

    if (result["user"]["id"] == _user.id) {
      MessageOutgoing message = MessageOutgoing.fromJson(result);

      _messages.add(
        ChatMessageOutgoing(
          message: message,
          animationController: new AnimationController(
            duration: new Duration(milliseconds: 700),
            vsync: this,
          ),
        ),
      );
    } else {
      MessageIncoming message = MessageIncoming.fromJson(result);

      _messages.add(
        ChatMessageIncoming(
          message: message,
          animationController: new AnimationController(
            duration: new Duration(milliseconds: 700),
            vsync: this,
          ),
        ),
      );
    }

    _messages.last.animationController.forward();
  }

  void addSocketMessage(result) {
    User _user = Provider.of<UserNotifier>(context, listen: false).user;

    if (result["user"]["id"] == _user.id) {
      MessageOutgoing message = MessageOutgoing.fromJson(result);

      _messages.insert(
        0,
        ChatMessageOutgoing(
          message: message,
          animationController: new AnimationController(
            duration: new Duration(milliseconds: 700),
            vsync: this,
          ),
        ),
      );
    } else {
      MessageIncoming message = MessageIncoming.fromJson(result);

      _messages.insert(
        0,
        ChatMessageIncoming(
          message: message,
          animationController: new AnimationController(
            duration: new Duration(milliseconds: 700),
            vsync: this,
          ),
        ),
      );
    }

    setState(() {
      _messages.first.animationController.forward();
    });

    Provider.of<ChatNotifier>(context, listen: false)
        .setLastMessage(widget.chat, _messages.first.message);
  }

  void initSocket() {
    _socketService.firePusher(_getChannelName, "App\\Events\\MessageEvent");

    _socketService.eventStream.listen(
      (data) {
        /*print("IN SOCKET");
        print("RESULT: $data");*/
        final result = json.decode(data);

        if (result["message"] != null) addSocketMessage(result["message"]);
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

  String get _getChannelName {
    return 'presence-190.chat.${widget.chat.id}';
  }

  void disconnectSocket() {
    _socketService.unSubscribePusher(_getChannelName);
  }
}

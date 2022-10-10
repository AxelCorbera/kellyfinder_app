import 'package:app/src/model/chat/message_incoming.dart';
import 'package:app/src/ui/widgets/chat/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/src/config/string_casing_extension.dart';

class ChatMessageIncoming extends StatelessWidget implements ChatMessage {
  final MessageIncoming message;
  final AnimationController animationController;

  ChatMessageIncoming({this.message, this.animationController});

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOutExpo,
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(right: 60.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: _getContent(context),
        ),
      ),
    );
  }

  Widget _getContent(context) {

    print( message.date);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      elevation: 2,
      color: Theme.of(context).accentColor,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
        message.text.toSentenceCase(),
              maxLines: null,
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 6),
            Text(
              message.getDate(context).toSentenceCase(),
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 10.0),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:app/src/model/chat/message_outgoing.dart';
import 'package:app/src/ui/widgets/chat/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/src/config/string_casing_extension.dart';

class ChatMessageOutgoing extends StatelessWidget implements ChatMessage {
  final MessageOutgoing message;
  final AnimationController animationController;

  ChatMessageOutgoing({this.message, this.animationController});

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOutExpo,
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(left: 60.0),
        child: Align(
          alignment: Alignment.centerRight,
          child: _getContent(context),
        ),
      ),
    );
  }

  Widget _getContent(context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        ),
      ),
      elevation: 2,
      color: Theme.of(context).primaryColorLight,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
        message.text.toSentenceCase(),
              style: TextStyle(color: Theme.of(context).accentColor),
              maxLines: null,
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 6),
            Text(
              message.getDate(context).toSentenceCase(),
              textAlign: TextAlign.end,
              style: TextStyle(
                color: Theme.of(context).accentColor,
                fontSize: 10.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/chat/chat.dart';
import 'package:app/src/ui/widgets/items/chat_list_item.dart';
import 'package:app/src/ui/widgets/layout/empty_list_layout.dart';
import 'package:flutter/material.dart';

class ChatList extends StatelessWidget {
  final List<Chat> chats;

  const ChatList({Key key, this.chats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (chats?.isNotEmpty ?? false)
      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: chats.length,
        itemBuilder: (BuildContext context, int index) {
          if (chats[index].contact != null)
            return ChatListItem(chat: chats[index]);

          return Container();
        },
        separatorBuilder: (BuildContext context, int index) {
          if (chats[index].contact != null) return Divider();
          return Container();
        },
      );
    return EmptyListLayout(
      text: AppLocalizations.of(context).translate("noResult"),
    );
  }
}

import 'package:app/src/api/api_provider.dart';
import 'package:app/src/model/chat/chat.dart';
import 'package:app/src/model/user.dart';
import 'package:app/src/provider/chat_notifier.dart';
import 'package:app/src/provider/socket_notifier.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/screens/chat/chat_screen.dart';
import 'package:app/src/ui/widgets/image/network_profile_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:app/src/config/string_casing_extension.dart';

class ChatListItem extends StatelessWidget {
  final Chat chat;

  const ChatListItem({Key key, this.chat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User _user = Provider.of<UserNotifier>(context, listen: false).user;

    return ListTile(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ChatScreen(chat: chat);
            },
          ),
        );

        Provider.of<UserNotifier>(context, listen: false)
            .initUserSocket(context);

        try {
          ApiProvider().performHasNewNotifications({}).then((result) {
            bool hasNewNotifications = result["has_new_requests"];
            bool hasNewChats = result["has_new_chats"];

            if (hasNewNotifications)
              Provider.of<SocketNotifier>(context, listen: false)
                  .addNewNotification();

            Provider.of<SocketNotifier>(context, listen: false)
                .addNewChat(hasNewChats);

            //if (hasNewChats)
            Provider.of<ChatNotifier>(context, listen: false)
                .updateUserChats(_user);
          });
        } catch (e) {
          print(e);
        }
      },
      leading: NetworkProfileImage(
        image: chat.contact.image,
        width: 48,
        height: 48,
      ),
      title: Row(
        children: <Widget>[
          Expanded(child: Text(chat.contact.name)),
          Text(
    chat.lastMessage?.getDate(context)?.toSentenceCase() ?? "",
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      ),
      subtitle: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(child: Text(chat.lastMessage?.text?.toSentenceCase() ?? "")),
          if (chat.lastMessage != null)
            if (!chat.lastMessage.hasBeenRead &&
                _user.id != chat.lastMessage.user.id)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
        ],
      ),
    );
  }
}

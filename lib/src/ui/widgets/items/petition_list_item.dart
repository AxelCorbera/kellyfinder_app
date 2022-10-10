import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/globals.dart' as globals;
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/model/chat/chat.dart';
import 'package:app/src/model/petition.dart';
import 'package:app/src/model/user.dart';
import 'package:app/src/provider/chat_notifier.dart';
import 'package:app/src/provider/socket_notifier.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/screens/archive/archive_details_screen.dart';
import 'package:app/src/ui/screens/chat/chat_screen.dart';
import 'package:app/src/ui/widgets/dialog/custom_dialog.dart';
import 'package:app/src/ui/widgets/image/network_profile_image.dart';
import 'package:app/src/utils/constants/petition_type.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/src/config/string_casing_extension.dart';
import 'package:provider/provider.dart';

class PetitionListItem extends StatefulWidget {
  final Petition petition;

  const PetitionListItem({Key key, this.petition}) : super(key: key);

  @override
  _PetitionListItemState createState() => _PetitionListItemState();
}

class _PetitionListItemState extends State<PetitionListItem> {
  @override
  Widget build(BuildContext context) {
    Archive archive = globals.petitionType == PetitionType.RECEIVED
        ? widget.petition.requesterCard
        : widget.petition.requestedCard;

    if (archive != null)
      return InkWell(
        onTap: () async {
          if (globals.petitionType == PetitionType.RECEIVED) {
            if(widget.petition.isActive){
              navigateTo(context, ArchiveDetailsScreen(archive: archive));
            }else{
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CustomDialog(
                    title: AppLocalizations.of(context)
                        .translate("mustAcceptRequest"),
                    buttonText:
                    AppLocalizations.of(context).translate("accept"),
                    hasCancel: false,
                  );
                },
              );
            }
          } else {
            if (widget.petition.isActive) {
              navigateTo(context, ArchiveDetailsScreen(archive: archive));
            } else {
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CustomDialog(
                    title: AppLocalizations.of(context)
                        .translate("mustWaitRequest"),
                    buttonText:
                        AppLocalizations.of(context).translate("accept"),
                    hasCancel: false,
                  );
                },
              );
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            spacing: 20,
                            children: <Widget>[
                              Text(
                          archive.name,
                                style: Theme.of(context).textTheme.subtitle2,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                archive.getDate(context).toSentenceCase(),
                                style: Theme.of(context).textTheme.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        RichText(
                          textAlign: TextAlign.start,
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyText2,
                            children: <TextSpan>[
                              TextSpan(
                                text: archive is Offer
                                    ? "${AppLocalizations.of(context).translate("offer")}: "
                                    : "${AppLocalizations.of(context).translate("demand")}: ",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              TextSpan(
                                text: archive.desc,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            InkWell(
                              onTap:
                                  globals.petitionType == PetitionType.RECEIVED
                                      ? () => _handleLock()
                                      : null,
                              child: Icon(
                                !widget.petition.isActive
                                    ? Icons.lock_outline
                                    : Icons.lock_open,
                                color: !widget.petition.isActive
                                    ? Colors.red
                                    : Colors.green,
                                size: 24,
                              ),
                            ),
                            Wrap(
                              spacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: <Widget>[
                                Icon(Icons.location_on),
                                Text(
                                  archive.locality,
                                  style: Theme.of(context).textTheme.caption,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Wrap(
                    direction: Axis.vertical,
                    spacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    children: <Widget>[
                      NetworkProfileImage(
                        image: archive.user.image,
                        width: 52,
                        height: 52,
                      ),
                      Text(
                        //"${AppLocalizations.of(context).translate("to")} ${archive?.distanceAsString}",
                        archive.distance != null ?
                        "${AppLocalizations.of(context).translate("to")} ${archive.distanceAsString}" :
                        "",
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      );

    User user = globals.petitionType == PetitionType.RECEIVED
        ? widget.petition.requesterUser
        : widget.petition.requestedUser;

    return InkWell(
      onTap: () async {
        Chat chat = await ApiProvider().performCreateRoom({
          "user_id": globals.petitionType == PetitionType.RECEIVED
              ? widget.petition.requesterUser.id
              : widget.petition.requestedUser.id,
          "type": archive is Offer ? "offer" : "demand"
        });

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

            User _user = Provider.of<UserNotifier>(context, listen: false).user;

            //if (hasNewChats)
            Provider.of<ChatNotifier>(context, listen: false)
                .updateUserChats(_user);
          });
        } catch (e) {
          print(e);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          spacing: 20,
                          children: <Widget>[
                            Text(
                        user.name,
                              style: Theme.of(context).textTheme.subtitle2,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              widget.petition.getDate(context),
                              style: Theme.of(context).textTheme.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      RichText(
                        textAlign: TextAlign.start,
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyText2,
                          children: <TextSpan>[
                            TextSpan(
                              text: archive is Offer
                                  ? "${AppLocalizations.of(context).translate("offer")}: "
                                  : "${AppLocalizations.of(context).translate("demand")}: ",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            TextSpan(text: widget.petition.comment),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          InkWell(
                            onTap: globals.petitionType == PetitionType.RECEIVED
                                ? () => _handleLock()
                                : null,
                            child: Icon(
                              !widget.petition.isActive
                                  ? Icons.lock_outline
                                  : Icons.lock_open,
                              color: !widget.petition.isActive
                                  ? Colors.red
                                  : Colors.green,
                              size: 24,
                            ),
                          ),
                          if (user.locality != null)
                            Wrap(
                              spacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: <Widget>[
                                Icon(Icons.location_on),
                                Text(
                                  user.locality,
                                  style: Theme.of(context).textTheme.caption,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Wrap(
                  direction: Axis.vertical,
                  spacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: <Widget>[
                    NetworkProfileImage(
                      image: user.image,
                      width: 52,
                      height: 52,
                    ),
                    Text(
                      widget.petition.requestedCard != null
                          ? (widget.petition.requestedCard?.distance != null ?
                      "${AppLocalizations.of(context).translate("to")} ${widget.petition.requestedCard?.distanceAsString}" :
                      "")
                      //"${AppLocalizations.of(context).translate("to")} ${widget.petition.requestedCard?.distanceAsString}"
                          : "",
                      style:
                          TextStyle(color: Theme.of(context).primaryColorLight),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future _handleLock() async {
    if (widget.petition.isActive) {
      await Provider.of<SocketNotifier>(context, listen: false)
          .refusePetition(widget.petition);
    } else {
      await Provider.of<SocketNotifier>(context, listen: false)
          .acceptPetition(widget.petition);
    }
  }
}

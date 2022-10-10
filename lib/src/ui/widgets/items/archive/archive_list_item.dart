import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/screens/archive/archive_details_screen.dart';
import 'package:app/src/ui/screens/archive/archive_select_card.dart';
import 'package:app/src/ui/widgets/dialog/custom_dialog.dart';
import 'package:app/src/ui/widgets/dialog/textfield_dialog.dart';
import 'package:app/src/ui/widgets/icon/custom_like_button.dart';
import 'package:app/src/ui/widgets/image/network_profile_image.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class ArchiveListItem extends StatefulWidget {
  final Archive archive;

  const ArchiveListItem({Key key, this.archive}) : super(key: key);

  @override
  _ArchiveListItemState createState() => _ArchiveListItemState();
}

class _ArchiveListItemState extends State<ArchiveListItem> {
  bool _likeLoading = false;
  bool _requestLoading = false;

  Offer offer;
  Demand demand;

  @override
  void initState() {
    super.initState();

    if (widget.archive is Offer) {
      offer = widget.archive;
    } else {
      demand = widget.archive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => performAction(context, widget.archive),
      child: Container(      color: Theme.of(context).primaryColorLight.withOpacity(0.15),

        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Container(
                            width: 30,
                            height: 30,
                            child: CustomLikeButton(
                              callback: _onLikeButtonTapped,
                              isLiked: widget.archive.isFavorite,
                            ),
                          ),
                          Text(
                            widget.archive.name.toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                .copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          widget.archive.category?.getParent?.type !=
                                      "shared" ??
                                  true
                              ? widget.archive.desc
                              : demand != null
                                  ? demand.observations
                                  : offer.observations,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Center(
                        child: Text(
                          //"A ${widget.archive.distanceAsString}",
                          widget.archive.distance != null ?
                          "${AppLocalizations.of(context).translate("to")} ${widget.archive.distanceAsString}" :
                          "",
                          style: TextStyle(
                            color: Theme.of(context).primaryColorLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                NetworkProfileImage(
                  image: widget.archive.user.image,
                  width: 88,
                  height: 88,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future performAction(BuildContext context, Archive archive) async {
    if (archive.user.id ==
        Provider.of<UserNotifier>(context, listen: false).user.id) {
      navigateTo(context, ArchiveDetailsScreen(archive: archive));
    } else if (archive.isAccepted) {
      navigateTo(context, ArchiveDetailsScreen(archive: archive));
    } else if (_requestLoading) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(
            title: AppLocalizations.of(context).translate("requestSending"),
            buttonText: AppLocalizations.of(context).translate("accept"),
            hasCancel: false,
          );
        },
      );
    } else if (archive.isSent) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(
            title: AppLocalizations.of(context).translate("requestAlready"),
            buttonText: AppLocalizations.of(context).translate("accept"),
            hasCancel: false,
          );
        },
      );
    } else if (archive.matchCard.isEmpty) {
      TextEditingController controller = TextEditingController();

      final result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return TextFieldDialog(
            title: AppLocalizations.of(context).translate("requestReason"),
            controller: controller,
            buttonText: AppLocalizations.of(context).translate("send"),
          );
        },
      );

      if (result == true) {
        requestCard(context, archive, comment: controller.text);
      }
    } else {
      final result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(
            title: AppLocalizations.of(context).translate("mustSendRequest"),
            buttonText: AppLocalizations.of(context).translate("accept"),
          );
        },
      );

      if (result == true) {
        int cardId =
            await navigateTo(context, ArchiveSelectCard(), isWaiting: true);

        if (cardId != null) {
          requestCard(context, archive, cardId: cardId);
        }
      }
    }
  }

  Future requestCard(BuildContext context, Archive archive,
      {String comment = "", int cardId}) async {
    try {
      setState(() {
        _requestLoading = true;
      });

      Map params = {
        "requested_card_id": archive.id,
        "requested_user_id": archive.user.id,
        "requester_user_id":
            Provider.of<UserNotifier>(context, listen: false).user.id,
      };

      if (cardId != null) {
        params.putIfAbsent("requester_card_id", () => cardId);
      } else {
        params.putIfAbsent("comment", () => comment);
      }

      final result = await ApiProvider().performRequestCard(params);

      setState(() {
        widget.archive.isAccepted =
            result["is_request_accepted"] == 1 ? true : false;
        widget.archive.isSent = result["is_request_sended"] == 1 ? true : false;
      });

      Scaffold.of(context).showSnackBar(SnackBar(
          content:
              Text(AppLocalizations.of(context).translate("requestSent"))));
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _requestLoading = false;
      });
    }
  }

  Future<bool> _onLikeButtonTapped(bool isLiked) async {
    if (!_likeLoading)
      try {
        Map result;

        setState(() {
          _likeLoading = true;
        });

        if (isLiked)
          result = await ApiProvider()
              .performUnMarkCardAsFavorite({"card_id": widget.archive.id});
        else
          result = await ApiProvider()
              .performMarkCardAsFavorite({"card_id": widget.archive.id});

        widget.archive.isFavorite =
            result["is_favorite_card"] == 1 ? true : false;

        setState(() {
          _likeLoading = false;
        });

        return widget.archive.isFavorite;
      } catch (e) {
        setState(() {
          _likeLoading = false;
        });
        return isLiked;
      }
  }

  bool hasReferences() {
    if (widget.archive is Offer) {
      Offer offer = widget.archive;

      return offer.hasReferences;
    } else {
      Demand demand = widget.archive;

      return demand.hasReferences;
    }
  }
}

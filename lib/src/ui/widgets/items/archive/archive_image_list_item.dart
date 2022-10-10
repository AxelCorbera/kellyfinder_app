import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/screens/archive/archive_details_screen.dart';
import 'package:app/src/ui/screens/archive/archive_select_card.dart';
import 'package:app/src/ui/widgets/dialog/custom_dialog.dart';
import 'package:app/src/ui/widgets/dialog/petition_dialog.dart';
import 'package:app/src/ui/widgets/dialog/petition_textfield_dialog.dart';
import 'package:app/src/ui/widgets/dialog/textfield_dialog.dart';
import 'package:app/src/ui/widgets/image/network_profile_image.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ArchiveImageListItem extends StatefulWidget {
  final double size;
  final Archive archive;

  const ArchiveImageListItem({Key key, this.size, this.archive})
      : super(key: key);

  @override
  _ArchiveImageListItemState createState() => _ArchiveImageListItemState();
}

class _ArchiveImageListItemState extends State<ArchiveImageListItem> {
  bool _requestLoading = false;

  @override
  Widget build(BuildContext context) {
    return NetworkProfileImage(
      width: widget.size,
      height: widget.size,
      image: widget.archive.user.image,
      function: () => performAction(context, widget.archive),
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
    /*else if (archive.matchCard == 0) {
      TextEditingController controller = TextEditingController();

      final result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return PetitionTextFieldDialog(
            archive: archive,
            controller: controller,
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
          return PetitionDialog(archive: archive);
        },
      );

      if (result == true) {
        requestCard(context, archive);
      }
    } */
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

  /*Future requestCard(BuildContext context, Archive archive,
      {String comment = ""}) async {
    if (!_requestLoading)
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

        if (archive.matchCard != 0) {
          params.putIfAbsent("requester_card_id", () => archive.matchCard);
        } else {
          params.putIfAbsent("comment", () => comment);
        }

        final result = await ApiProvider().performRequestCard(params);

        setState(() {
          widget.archive.isAccepted =
              result["is_request_accepted"] == 1 ? true : false;
          widget.archive.isSent =
              result["is_request_sended"] == 1 ? true : false;
        });

        Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context).translate("requestSent"))));

        return true;
      } catch (e) {
        print(e);
      } finally {
        setState(() {
          _requestLoading = false;
        });
      }
  }*/
}

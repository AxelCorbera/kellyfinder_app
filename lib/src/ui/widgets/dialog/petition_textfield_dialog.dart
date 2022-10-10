import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/sentence_case_text_formatter.dart';
import 'package:app/src/config/string_casing_extension.dart';
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/ui/widgets/icon/custom_like_button.dart';
import 'package:app/src/ui/widgets/image/network_profile_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PetitionTextFieldDialog extends StatefulWidget {
  final Archive archive;
  final TextEditingController controller;

  const PetitionTextFieldDialog({Key key, this.archive, this.controller})
      : super(key: key);

  @override
  _PetitionTextFieldDialogState createState() =>
      _PetitionTextFieldDialogState();
}

class _PetitionTextFieldDialogState extends State<PetitionTextFieldDialog> {
  bool _likeLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Container(
                            child: CustomLikeButton(
                              callback: _onLikeButtonTapped,
                              isLiked: widget.archive.isFavorite,
                            ),
                            width: 30,
                            height: 30,
                          ),
                          Text(
                            widget.archive.name,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                .copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.archive.desc.toSentenceCase(),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 12),
                      Wrap(
                        direction: Axis.vertical,
                        spacing: 12,
                        children: <Widget>[
                          Wrap(
                            spacing: 4,
                            children: <Widget>[
                              Icon(Icons.location_on),
                              Text(
                                widget.archive.locality,
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ],
                          ),
                          Wrap(
                            spacing: 4,
                            children: <Widget>[
                              Icon(Icons.calendar_today),
                              Text(
                                widget.archive.getDate(context).toSentenceCase(),
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ],
                          ),
                          Wrap(
                            children: <Widget>[
                              Text(
                                "${AppLocalizations.of(context).translate("nationality")}: ",
                                style: Theme.of(context).textTheme.caption,
                              ),
                              Text(
                                widget.archive.nationality,
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Wrap(
                  direction: Axis.vertical,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  children: <Widget>[
                    NetworkProfileImage(
                      image: widget.archive.user.image,
                      width: 52,
                      height: 52,
                    ),
                    Text(
                      //"${AppLocalizations.of(context).translate("to")} ${widget.archive.distanceAsString}",
                      widget.archive.distance != null ?
                      "${AppLocalizations.of(context).translate("to")} ${widget.archive.distanceAsString}" :
                      "",
                      style:
                          TextStyle(color: Theme.of(context).primaryColorLight),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            TextField(
              inputFormatters: [
                SentenceCaseTextFormatter()
              ],
              controller: widget.controller,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).translate("addComment"),
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        SimpleDialogOption(
          child: Text(
            AppLocalizations.of(context).translate("close").toUpperCase(),
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        SimpleDialogOption(
          child: Text(
            AppLocalizations.of(context).translate("sendRequest").toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    );
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
}

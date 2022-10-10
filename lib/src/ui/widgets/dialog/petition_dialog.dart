import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/ui/widgets/image/network_profile_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/src/config/string_casing_extension.dart';

class PetitionDialog extends StatelessWidget {
  final Archive archive;

  const PetitionDialog({Key key, this.archive}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
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
                        Icon(
                          Icons.favorite_border,
                          color: Colors.red,
                          size: 20,
                        ),
                        Text(
                          archive.name,
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
                      archive.desc.toSentenceCase(),
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
                              archive.locality,
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ],
                        ),
                        Wrap(
                          spacing: 4,
                          children: <Widget>[
                            Icon(Icons.calendar_today),
                            Text(
                              archive.getDate(context).toSentenceCase(),
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
                              archive.nationality,
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
                    image: archive.user.image,
                    width: 52,
                    height: 52,
                  ),
                  Text(
                    //"${AppLocalizations.of(context).translate("to")} ${archive.distanceAsString}",
                    archive.distance != null ?
                    "${AppLocalizations.of(context).translate("to")} ${archive.distanceAsString}" :
                    "",
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight),
                  ),
                ],
              ),
            ],
          ),
        ],
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
                fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }
}

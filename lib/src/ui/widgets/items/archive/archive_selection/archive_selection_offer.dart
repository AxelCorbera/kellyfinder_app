import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/globals.dart' as globals;
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/provider/category_notifier.dart';
import 'package:app/src/ui/screens/add_archive/archive_demand_screen.dart';
import 'package:app/src/ui/screens/add_archive/archive_offer_screen.dart';
import 'package:app/src/ui/widgets/image/network_profile_image.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/src/config/string_casing_extension.dart';
import 'package:provider/provider.dart';

class ArchiveSelectionOffer extends StatefulWidget {
  final Archive archive;

  const ArchiveSelectionOffer({Key key, this.archive}) : super(key: key);

  @override
  _ArchiveSelectionOfferState createState() => _ArchiveSelectionOfferState();
}

class _ArchiveSelectionOfferState extends State<ArchiveSelectionOffer> {
  @override
  Widget build(BuildContext context) {
    Offer offer;
    Demand demand;

    if (widget.archive is Offer) {
      offer = widget.archive;
    } else {
      demand = widget.archive;
    }

    return InkWell(
      onTap: () {
        CategoryNotifier notifier =
            Provider.of<CategoryNotifier>(context, listen: false);

        if (globals.archiveType == Demand) {
          notifier.selectCategory(demand.category.getParent);
          notifier.selectSubcategory(demand.category);

          navigateTo(context, ArchiveDemandScreen(demand: demand));
        } else if (globals.archiveType == Offer) {
          notifier.selectCategory(offer.category.getParent);
          notifier.selectSubcategory(offer.category);

          navigateTo(context, ArchiveOfferScreen(offer: offer));
        }
      },
      child: Container(
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
                      SizedBox(height: 16),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Wrap(
                          spacing: 24,
                          runSpacing: 12,
                          alignment: WrapAlignment.spaceBetween,
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
                            if (hasReferences())
                              Wrap(
                                spacing: 4,
                                children: <Widget>[
                                  Icon(Icons.check_box),
                                  Text(
                                    AppLocalizations.of(context)
                                        .translate("references"),
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                ],
                              ),
                          ],
                        ),
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
                      image: widget.archive.user.image,
                      width: 52,
                      height: 52,
                    ),
                  ],
                )
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  if (widget.archive.nationality?.isNotEmpty ?? false)
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

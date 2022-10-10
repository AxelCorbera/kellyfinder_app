import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/model/category.dart';
import 'package:app/src/ui/screens/archive/archive_details_screen.dart';
import 'package:app/src/ui/widgets/image/network_profile_image.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CompanyListItem extends StatelessWidget {
  final Company company;
  final Category category;

  const CompanyListItem({Key key, this.company, this.category})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        navigateTo(context, ArchiveDetailsScreen(archive: company));
      },
      child: Container(color: Theme.of(context).primaryColorLight.withOpacity(0.15),

        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              company.name.toUpperCase(),
                              style: Theme.of(context).textTheme.subtitle2,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            Text(
                              company.desc,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                        company.distance != null ?
                        "${AppLocalizations.of(context).translate("to")} ${company.distanceAsString}" :
                            "",
                      style:
                          TextStyle(color: Theme.of(context).primaryColorLight),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            NetworkProfileImage(
              image: company.user.image,
              width: 88,
              height: 88,
            ),
          ],
        ),
      ),
    );
  }
}

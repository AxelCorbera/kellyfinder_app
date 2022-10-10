import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/provider/category_notifier.dart';
import 'package:app/src/ui/screens/add_archive/archive_company_screen.dart';
import 'package:app/src/ui/widgets/image/network_profile_image.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:app/src/config/string_casing_extension.dart';

class ArchiveSelectionCompany extends StatelessWidget {
  final Company company;

  const ArchiveSelectionCompany({Key key, this.company}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        CategoryNotifier notifier =
            Provider.of<CategoryNotifier>(context, listen: false);

        if (company.category.parentCategory != null) {
          notifier.selectCategory(company.category.getParent);
          notifier.selectSubcategory(company.category);
        } else {
          notifier.selectCategory(company.category);
        }

        if(company.industrialParkCategory != null){
          navigateTo(context, ArchiveCompanyScreen(company: company, industrialParkCategory: company.industrialParkCategory,));
        }else{
          navigateTo(context, ArchiveCompanyScreen(company: company));
        }
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                            ),
                            SizedBox(height: 6),
                            Container(
                              child: Text(
                                company.desc.toSentenceCase(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.location_on),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          company.direction,
                          style: Theme.of(context).textTheme.caption,
                          maxLines: null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 4,
                    children: <Widget>[
                      Icon(Icons.language),
                      Text(
                        (company.web != "" ? company.web : "-"),
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  if (company.safeText(context).isNotEmpty)
                    Column(
                      children: <Widget>[
                        Wrap(
                          spacing: 4,
                          children: <Widget>[
                            Icon(Icons.check),
                            Text(
                              company.safeText(context),
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
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
                  image: company.user.image,
                  width: 52,
                  height: 52,
                ),
                Text(
                  //"${AppLocalizations.of(context).translate("to")} ${company.distanceAsString}",
                  company.distance != null ?
                  "${AppLocalizations.of(context).translate("to")} ${company.distanceAsString}" :
                  "",
                  style: TextStyle(color: Theme.of(context).primaryColorLight),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

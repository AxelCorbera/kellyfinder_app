import 'dart:ui';

import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/globals.dart' as globals;
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/model/category.dart';
import 'package:app/src/model/user.dart';
import 'package:app/src/provider/category_notifier.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/icons/category_icons.dart';
import 'package:app/src/ui/screens/add_archive/archive_company_screen.dart';
import 'package:app/src/ui/screens/category/category_screen.dart';
import 'package:app/src/ui/screens/category/category_hours_screen.dart';
import 'package:app/src/ui/widgets/dialog/custom_dialog.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryGridItem extends StatelessWidget {
  final Category category;
  final bool disabled;
  final bool isArchive;
  final bool isGrid;

  const CategoryGridItem(
      {Key key,
      this.category,
      this.disabled = false,
      this.isArchive,
      this.isGrid = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      child: Opacity(
        opacity: disabled ? 0.4 : 1,
        child: Material(
          elevation: 4.0,
          color: Theme.of(context).disabledColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          clipBehavior: Clip.hardEdge,
          child: Ink.image(
            image: NetworkImage(category.image),
            fit: BoxFit.cover,
            colorFilter: category.type != "24h"
                ? ColorFilter.mode(
                    category.color.withOpacity(0.6),
                    BlendMode.srcOver,
                  )
                : null,
            child: InkWell(
              onTap: () {
                if (!disabled) {
                  Provider.of<CategoryNotifier>(context, listen: false)
                      .selectCategory(category);

                  _performNavigation(context);
                } else {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomDialog(
                          title: AppLocalizations.of(context)
                              .translate("disabledOption"),
                          hasCancel: false,
                        );
                      });
                }
              },
              child: category.type != "24h"
                  ? Center(
                      child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: AutoSizeText(
                        category.name.toUpperCase(),
                        maxLines: 1,
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              color: Theme.of(context).accentColor,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ))
                  : Container(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: new Builder(builder: (context) {
                            return new Icon(
                              CategoryIcons.allDay,
                              color: Theme.of(context).accentColor,
                              size: MediaQuery.of(context).size.height,
                            );
                          }),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future _performNavigation(BuildContext context) async {
    try {
      // Si en la app hay >200 fichas
      final result = await ApiProvider().performHasEnoughCards({});

      AppUser appUser =
          Provider.of<UserNotifier>(context, listen: false).appUser;

      if(!isArchive){
        // Si el usuario no tiene fichas creadas
        // Y no se han superado las 200 en la base de datos
        // No le deja buscar
        /*if (!appUser.hasCards && result == false) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomDialog(
                title: AppLocalizations.of(context).translate("fillArchive"),
              );
            },
          );
          return;
        }*/
      }

      //if (appUser.hasCards || result == true) {
        if (!isArchive) {
          if (!isGrid){
            navigateTo(context, CategoryScreen(isArchive: false));
          } else{
            navigateTo(context, CategoryHoursScreen(isArchive: false));
          }
        } else {
          if (category.type == "hostelry"){
            navigateTo(context, ArchiveCompanyScreen());
          } else if (category.canAdvertise &&
              globals.archiveType == Company &&
              isArchive) {
            navigateTo(context, ArchiveCompanyScreen());
          } else {
            if (!isGrid){
              navigateTo(context, CategoryScreen(isArchive: true));
            } else {
              navigateTo(context, CategoryHoursScreen(isArchive: true));
            }
          }
        }
      /*} else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialog(
              title: AppLocalizations.of(context).translate("fillArchive"),
            );
          },
        );
      }*/
    } catch (e) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text(catchErrors(e, null))));
    }
  }
}

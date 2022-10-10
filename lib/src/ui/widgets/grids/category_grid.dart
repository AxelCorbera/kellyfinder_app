import 'package:app/src/config/globals.dart' as globals;
import 'package:app/src/model/category.dart';
import 'package:app/src/provider/category_notifier.dart';
import 'package:app/src/ui/widgets/items/category/category_grid_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/archive/archive.dart';
import '../../../utils/constants/searching_type.dart';

class CategoryGrid extends StatelessWidget {
  final bool hasDisable;
  final bool isArchive;

  final String from;

  const CategoryGrid({
    Key key,
    this.hasDisable = false,
    this.isArchive = false,
    this.from,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool compartidosDisabled = true;

    List<Category> _categories =
        Provider.of<CategoryNotifier>(context, listen: false).categories;

    // Comprobamos si COMPARTIDOS debe estar activado o desactivado
    // Si viene de PERFIL y selecciona oferta: activado, si no: desactivado
    // Si viene de INICIO y selecciona oferta: activado, si no: desactivado
    if (isArchive) {
      compartidosDisabled = (globals.archiveType == Offer ? false : true);
    } else {
      compartidosDisabled =
          (globals.searchingType == SearchingType.OFFER ? false : true);
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: CategoryGridItem(
                          category: _categories[0],
                          isArchive: isArchive,
                        ),
                      ),
                      Expanded(
                        child: CategoryGridItem(
                          category: _categories[1],
                          isArchive: isArchive,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CategoryGridItem(
                    category: _categories[2],
                    isArchive: isArchive,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: CategoryGridItem(
              category: _categories[3],
              disabled: hasDisable,
              isArchive: isArchive,
              isGrid: true,
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: CategoryGridItem(
                          disabled: hasDisable,
                          category: _categories[6],
                          isArchive: isArchive,
                        ),
                      ),
                      Expanded(
                        child: CategoryGridItem(
                          disabled: compartidosDisabled,
                          category: _categories[4],
                          isArchive: isArchive,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: CategoryGridItem(
                          category: _categories[5],
                          disabled: hasDisable,
                          isArchive: isArchive,
                        ),
                      ),
                      Expanded(
                        child: CategoryGridItem(
                          category: _categories[7],
                          disabled: hasDisable,
                          isArchive: isArchive,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

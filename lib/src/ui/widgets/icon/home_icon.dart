import 'package:app/src/ui/screens/add_archive/archive_category_screen.dart';
import 'package:app/src/ui/widgets/navigation_bar.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class HomeIcon extends StatelessWidget {
  final Color color;
  final bool isArchive;

  const HomeIcon({Key key, this.color, this.isArchive}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        MaterialCommunityIcons.home_outline,
        color: color ?? Theme.of(context).primaryColor,
      ),
      onPressed: () {
        navigateTo(context, NavigationBar(), willPop: true);

        /*if(isArchive == null || !isArchive){
          navigateTo(context, NavigationBar(), willPop: true);
        }else{
          // Si está publicando ficha, no tiene sentido que vaya a la NavigationBar
          // En este caso, volverá al selector de categoría
          while(Navigator.canPop(context)){
            Navigator.pop(context);
          }

          navigateTo(context, ArchiveCategoryScreen());
        }*/
      },
    );
  }
}

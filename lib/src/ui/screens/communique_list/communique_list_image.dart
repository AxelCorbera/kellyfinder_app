import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/app_styles.dart';
import 'package:app/src/model/municipality/communique.dart';
import 'package:app/src/ui/screens/archive/archive_image_screen.dart';
import 'package:app/src/ui/screens/communique_list/communique_image_viewer.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';

class CommuniqueListImage extends StatelessWidget {
  final Communique communique;

  CommuniqueListImage({this.communique});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          AppLocalizations.of(context).translate("message").toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Text(
          communique.description != "" ? communique.description : "-",
          style: TextStyle(
            color: AppStyles.lightGreyColor,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: (){
                  navigateTo(context, CommuniqueImageViewer(image: communique.media,));
                },
                child: Image.network(
                  communique.media,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

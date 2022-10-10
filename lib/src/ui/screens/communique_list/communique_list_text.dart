import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/app_styles.dart';
import 'package:app/src/model/municipality/communique.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/src/config/string_casing_extension.dart';

class CommuniqueListText extends StatelessWidget {
  final Communique communique;

  CommuniqueListText({this.communique});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: 42),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AppLocalizations.of(context).translate("message").toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
    communique.description.toSentenceCase(),
                  style: TextStyle(
                    color: AppStyles.lightGreyColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

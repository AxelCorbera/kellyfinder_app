import 'package:app/src/config/app_styles.dart';
import 'package:flutter/material.dart';

class MunicipalityInfoText extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData titleIcon;

  const MunicipalityInfoText(
      {Key key, this.title, this.subtitle, this.titleIcon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyText2.copyWith(color: AppStyles.lightGreyColor,fontWeight: FontWeight.w600,),
      ),
      subtitle: Container(
        padding: EdgeInsets.only(top: 8),
        child: Row(
          children: [
            if(titleIcon != null)
            Icon(titleIcon, color: AppStyles.bgMunicipalityDetailsAppBar,),
            if(titleIcon != null)
            SizedBox(width: 4),
            Expanded(
              child: Text(
                subtitle,
                style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

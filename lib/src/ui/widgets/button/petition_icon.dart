import 'package:app/src/config/app_styles.dart';
import 'package:app/src/provider/socket_notifier.dart';
import 'package:app/src/ui/screens/petition/petitions_screen.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PetitionIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SocketNotifier>(
      builder: (context, notifier, child) {


        if (notifier.newNotification)
          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.notifications,
                  color: AppStyles.lightGreyColor,
                ),
                onPressed: () => navigateTo(context, PetitionScreen()),
              ),
              Positioned(
                right: 14,
                top: 20,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          );

        return IconButton(
          icon: Icon(Icons.notifications, color: AppStyles.lightGreyColor),
          onPressed: () => navigateTo(context, PetitionScreen()),
        );
      },
    );
  }
}

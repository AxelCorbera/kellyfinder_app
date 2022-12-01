import 'dart:convert';
import 'dart:developer';

import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/app_styles.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/screens/profile/ProfileRaffle.dart';
import 'package:app/src/ui/screens/profile/settings_screen.dart';
import 'package:app/src/ui/widgets/image/network_profile_image.dart';
import 'package:app/src/ui/widgets/lists/archive_icon_list.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:app/src/config/string_casing_extension.dart';

class NavProfileScreen extends StatefulWidget {
  @override
  _NavProfileScreenState createState() => _NavProfileScreenState();
}

class _NavProfileScreenState extends State<NavProfileScreen> {
  bool _raffleActive = false;
  String _raffleVideo;
  String _raffleCode;
  String numLottery = '-';

  @override
  void initState() {
    _checkRaffle();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle:true,
        title: Text(
          AppLocalizations.of(context).translate("profile"),
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings, color: AppStyles.lightGreyColor),
            onPressed: () => navigateTo(context, SettingsScreen()),
          )
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    //User user = Provider.of<UserNotifier>(context, listen: false).user;

    return Consumer<UserNotifier>(
      builder: (context, notifier, child) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      NetworkProfileImage(
                        image: notifier.user.image,
                        width: 80,
                        height: 80,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                                notifier.user.name,
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.email,
                                  color: AppStyles.lightGreyColor,
                                ),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    notifier.user.email,
                                    style: Theme.of(context).textTheme.caption,
                                    maxLines: null,
                                  ),
                                ),
                              ],
                            ),
                            if(numLottery!=null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    'Número de loteria: ',
                                    style: Theme.of(context).textTheme.caption,
                                    maxLines: null,
                                  ),
                                  Text(
                                    numLottery,
                                    style: Theme.of(context).textTheme.caption,
                                    maxLines: null,
                                  ),
                                ],
                              ),
                            ),
                            if (_raffleActive)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: GestureDetector(
                                  onTap: () => navigateTo(
                                      context,
                                      ProfileRaffle(
                                        videoUrl: _raffleVideo,
                                        raffleCode: _raffleCode,
                                      )),
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate("profile_raffle"),
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 32),
                  Text(
                    AppLocalizations.of(context).translate("archives"),
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            child,
          ],
        );
      },
      child: Expanded(child: ArchiveIconList()),
    );
  }

  Future _checkRaffle() async {
    final response =
    await ApiProvider().performCheckLotery(Provider.of<UserNotifier>(context, listen: false).user.id.toString());
    var json = jsonDecode(response);
    numLottery = json['num_loteria'];
    final result = await ApiProvider().performIsLotteryActive(
        {"user_id": Provider.of<UserNotifier>(context, listen: false).user.id});

    setState(() {
      _raffleActive = result['is_active'];
      _raffleVideo = result['video_url'];
      _raffleCode = result['code'];
    });
  }
}

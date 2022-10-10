import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/app_styles.dart';
import 'package:app/src/model/category.dart';
import 'package:app/src/provider/category_notifier.dart';
import 'package:app/src/provider/socket_notifier.dart';
import 'package:app/src/ui/screens/communique_list/communique_list_screen.dart';
import 'package:app/src/ui/widgets/button/petition_icon.dart';
import 'package:app/src/ui/widgets/button/search_slider_button.dart';
import 'package:app/src/ui/widgets/dialog/custom_dialog.dart';
import 'package:app/src/ui/widgets/grids/category_grid.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';

class NavHomeScreen extends StatefulWidget {
  @override
  _NavHomeScreenState createState() => _NavHomeScreenState();
}

class _NavHomeScreenState extends State<NavHomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future _futureCategories;

  @override
  void initState() {
    super.initState();
    _futureCategories = _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate("home"),
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: <Widget>[
          IconButton(
            color: AppStyles.lightGreyColor,
            icon: Icon(MaterialCommunityIcons.bullhorn),
            onPressed: () {
              navigateTo(context, CommuniqueListScreen());
            },
          ),
          IconButton(
            color: AppStyles.lightGreyColor,
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CustomDialog(
                    title: AppLocalizations.of(context)
                            .translate("dialogCreateCard1") +
                        "\n \n" +
                        AppLocalizations.of(context)
                            .translate("dialogCreateCard2") +
                        "\n \n" +
                        AppLocalizations.of(context)
                            .translate("dialogCreateCard3"),
                    hasCancel: false,
                  );
                },
              );
            },
          ),
          PetitionIcon(),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 16),
        SearchSliderButton(
          callback: () {
            setState(() {});
          },
        ),
        Expanded(
          child: FutureBuilder(
            future: _futureCategories,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return CategoryGrid(
                    from: "search",
                  );
                }
              }
              return FutureCircularIndicator();
            },
          ),
        ),
      ],
    );
  }

  Future _getData() async {
    if (!Provider.of<CategoryNotifier>(context, listen: false).isFilled)
      try {
        List<Category> categories =
            await ApiProvider().performGetCategories({});

        Provider.of<CategoryNotifier>(context, listen: false)
            .fillCategories(categories);

        final result = await ApiProvider().performHasNewNotifications({});

        print(result);

        bool hasNewNotifications = result["has_new_requests"];
        bool hasNewChats = result["has_new_chats"];

        if (hasNewNotifications)
          Provider.of<SocketNotifier>(context, listen: false)
              .addNewNotification();

        if (hasNewChats)
          Provider.of<SocketNotifier>(context, listen: false).addNewChat(true);

        return true;
      } catch (e) {
        catchErrors(e, _scaffoldKey);
      }
    else
      return true;
  }
}

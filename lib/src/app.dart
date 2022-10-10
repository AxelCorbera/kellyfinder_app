import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/app_themes.dart';
import 'package:app/src/config/globals.dart' as globals;
import 'package:app/src/model/user.dart';
import 'package:app/src/provider/category_notifier.dart';
import 'package:app/src/provider/chat_notifier.dart';
import 'package:app/src/provider/socket_notifier.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/screens/sign_in/sign_in_screen.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/ui/widgets/navigation_bar.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/cache/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future _futureSharedUser;

  bool _isChecked;

  @override
  void initState() {
    super.initState();

    _futureSharedUser = getSharedUser();

    _isChecked = false;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserNotifier()),
        ChangeNotifierProvider(create: (_) => CategoryNotifier()),
        ChangeNotifierProvider(create: (_) => ChatNotifier()),
        ChangeNotifierProvider(create: (_) => SocketNotifier()),
      ],
      child: MaterialApp(
        navigatorKey: globals.navigatorKey,
        title: "KellyFinder",
        theme: Themes.appTheme,
        darkTheme: Themes.appTheme,
        debugShowCheckedModeBanner: false,
        supportedLocales: [
          Locale('en'),
          Locale('ca'),
          Locale('es'),
        ],
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: FutureBuilder(
          future: _futureSharedUser,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              initErrors(context);

              if (snapshot.hasData) {
                if (!_isChecked) {
                  Provider.of<UserNotifier>(context, listen: false)
                      .initUser(snapshot.data);

                  Provider.of<UserNotifier>(context, listen: false)
                      .initUserSocket(context);

                  _isChecked = true;
                }

                return NavigationBar();
              } else {
                return SignInScreen();
              }
            }
            return FutureCircularIndicator();
          },
        ),
      ),
    );
  }

  Future getSharedUser() async {
    try {
      AppUser appUser = await Preferences.getSharedUser();

      return appUser;
    } catch (e) {
      print(e);
      return null;
    }
  }
}

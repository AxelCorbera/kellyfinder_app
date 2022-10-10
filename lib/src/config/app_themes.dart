import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Themes {
  static final appTheme = ThemeData(
    fontFamily: 'Raleway',
    primaryColor: Color(0xFFFF6D00),
    primaryColorLight: Color(0xFFFF9E40),
    accentColor: Colors.white,
    disabledColor: Colors.grey[100],
    buttonColor: Color(0xFFFF6D00),
    brightness: Brightness.light,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFFF6D00),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    ),
    errorColor: Colors.red,
    appBarTheme: AppBarTheme(
      elevation: 4,

      color: Colors.white,
      textTheme: TextTheme(
        headline6: TextStyle(
          fontFamily: "Raleway",
          color: Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
      ),
      iconTheme: IconThemeData(color: Color(0xFFFF6D00)),
      actionsIconTheme: IconThemeData(color: Color(0xFFFF6D00)),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Color(0xFFFF6D00),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
    ),
    scaffoldBackgroundColor: Colors.white,
    iconTheme: IconThemeData(color: Color(0xFFFF6D00), size: 16),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      titleTextStyle: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.normal,
        color: Colors.black54,
        fontFamily: "Raleway",
      ),
      contentTextStyle: TextStyle(
        fontSize: 14.0,
        color: Colors.black54,
        fontFamily: "Raleway",
      ),
    ),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
    textTheme: TextTheme(
      headline4: TextStyle(),
      headline5: TextStyle(),
      headline6: TextStyle(),
      subtitle1: TextStyle(),
      subtitle2: TextStyle(),
      bodyText1: TextStyle(),
      bodyText2: TextStyle(),
      button: TextStyle(
        color: Colors.white,
      ),
      //Grey BodyText
      caption: TextStyle(fontSize: 14),
      overline: TextStyle(),
    ),
  );
}

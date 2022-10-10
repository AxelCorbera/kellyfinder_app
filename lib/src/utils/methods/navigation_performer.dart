import 'package:flutter/material.dart';

navigateTo(BuildContext context, Widget route,
    {bool willPop = false, bool isWaiting = false}) async {
  if (willPop) {


    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
      builder: (context) {
        return route;
      },
    ), (_) => false);
  } else if (isWaiting) {
    final data = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return route;
        },
      ),
    );

    return data;
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return route;
        },
      ),
    );
  }
}

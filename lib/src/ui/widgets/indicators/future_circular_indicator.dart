import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FutureCircularIndicator extends StatelessWidget {
  final bool isButton;

  const FutureCircularIndicator({Key key, this.isButton = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(
          isButton
              ? Theme.of(context).accentColor
              : Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

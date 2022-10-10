import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:flutter/material.dart';

class CustomFutureButton extends StatelessWidget {
  final Future future;
  final Function callback;
  final String text;

  const CustomFutureButton({Key key, this.callback, this.text, this.future})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 40,
      child: FloatingActionButton.extended(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        onPressed: callback,
        label: FutureBuilder(
          future: future,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 28,
                width: 28,
                child: FutureCircularIndicator(isButton: true),
              );
            }

            return Text(
              text.toUpperCase() ??
                  AppLocalizations.of(context).translate("done").toUpperCase(),
              style: Theme.of(context)
                  .textTheme
                  .button
                  .copyWith(fontWeight: FontWeight.w800),
            );
          },
        ),
      ),
    );
  }
}

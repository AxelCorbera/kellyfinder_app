import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Function function;
  final String text;

  const CustomButton({Key key, this.function, this.text = "DONE"})
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
        onPressed: function,
        label: Text(
          text.toUpperCase(),
          style: Theme.of(context)
              .textTheme
              .button
              .copyWith(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

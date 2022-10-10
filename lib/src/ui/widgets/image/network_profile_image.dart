import 'package:flutter/material.dart';

class NetworkProfileImage extends StatelessWidget {
  final String image;
  final double width;
  final double height;
  final Function function;

  const NetworkProfileImage(
      {Key key, this.image, this.width = 52, this.height = 52, this.function})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4.0,
      color: Theme.of(context).disabledColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Ink.image(
        image: NetworkImage(image),
        fit: BoxFit.cover,
        width: width,
        height: height,
        child: InkWell(
          onTap: function,
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';

class FileProfileImage extends StatelessWidget {
  final File image;
  final double width;
  final double height;
  final Function function;

  const FileProfileImage(
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
        image: FileImage(image),
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

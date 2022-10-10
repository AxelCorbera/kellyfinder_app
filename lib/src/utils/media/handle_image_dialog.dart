import 'dart:io';

import 'package:app/src/config/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum ImgProvider { gallery, camera }

Future<File> handleImageDialog(BuildContext context) async {
  File _image;
  final _picker = ImagePicker();

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text(AppLocalizations.of(context).translate("choose")),
        children: <Widget>[
          SimpleDialogOption(
            onPressed: () async {
              final pickedFile = await _picker.getImage(
                  source: ImageSource.camera, maxHeight: 1024, maxWidth: 1024);

              _image = File(pickedFile.path);

              Navigator.pop(context);
            },
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Icon(Icons.camera_alt),
                ),
                Text(AppLocalizations.of(context).translate("camera")),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () async {
              final pickedFile = await _picker.getImage(
                  source: ImageSource.gallery, maxHeight: 1024, maxWidth: 1024);

              if (pickedFile != null) {
                _image = File(pickedFile.path);
              }

              Navigator.pop(context);
            },
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Icon(Icons.photo),
                ),
                Text(AppLocalizations.of(context).translate("gallery")),
              ],
            ),
          ),
        ],
      );
    },
  );

  return _image;
}

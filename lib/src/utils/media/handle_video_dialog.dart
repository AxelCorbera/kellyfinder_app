import 'dart:io';

import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/ui/widgets/dialog/progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';

enum ImgProvider { gallery, camera }

Future<File> handleVideoDialog(BuildContext context,{int duration = 1}) async {
  File _image;
  final _picker = ImagePicker();

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text(AppLocalizations.of(context).translate("selectVideo")),
        children: <Widget>[
          SimpleDialogOption(
            onPressed: () async {
              final pickedFile = await _picker.getVideo(
                source: ImageSource.camera,
                maxDuration: Duration(minutes: duration),
              );

              if(pickedFile != null) {
                _image = await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return ProgressDialog(
                      pickedFile: pickedFile,
                    );
                  },
                );

                Navigator.pop(context);
              }
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
              final pickedFile = await _picker.getVideo(
                source: ImageSource.gallery,
                maxDuration: Duration(minutes: duration),
              );

              if(pickedFile != null){
                _image = await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return ProgressDialog(
                      pickedFile: pickedFile,
                    );
                  },
                );

                Navigator.pop(context);
              }

              //_image = File(mediaInfo.path);
              //_image = File(pickedFile.path);

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

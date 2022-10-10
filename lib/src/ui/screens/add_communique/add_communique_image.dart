import 'dart:io';

import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/app_styles.dart';
import 'package:app/src/utils/media/handle_image_dialog.dart';
import 'package:flutter/material.dart';

class AddCommuniqueImage extends StatefulWidget {
  final File image;
  final Function callback;

  const AddCommuniqueImage({Key key, this.image, this.callback})
      : super(key: key);

  @override
  _AddCommuniqueImageState createState() => _AddCommuniqueImageState();
}

class _AddCommuniqueImageState extends State<AddCommuniqueImage> {
  @override
  Widget build(BuildContext context) {
    if (widget.image != null)
      return InkWell(
        onTap: () async {
          final result = await handleImageDialog(context);

          if (result != null) {
            widget.callback(result);
          }
        },
        child: Image.file(
          widget.image,
          fit: BoxFit.fitWidth,
        ),
      );

    return Column(
      children: <Widget>[
        SizedBox(height: 24),
        if (widget.image == null)
          Center(
            child: ClipOval(
              child: Material(
                color: Theme.of(context).primaryColorLight.withOpacity(0.5),
                child: InkWell(
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: Icon(Icons.camera_alt, size: 24),
                  ),
                  onTap: () async {
                    final result = await handleImageDialog(context);

                    if (result != null) {
                      widget.callback(result);
                    }
                  },
                ),
              ),
            ),
          ),
        SizedBox(height: 16),
        Center(
          child: Text(
            AppLocalizations.of(context).translate("addImage"),
            style: TextStyle(color: AppStyles.lightGreyColor),
          ),
        ),
        SizedBox(height: 32),
      ],
    );
  }
}

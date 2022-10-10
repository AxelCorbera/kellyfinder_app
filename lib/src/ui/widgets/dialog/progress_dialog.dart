import 'dart:io';

import 'package:app/src/config/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:video_compress/video_compress.dart';

class ProgressDialog extends StatefulWidget {
  final PickedFile pickedFile;

  const ProgressDialog({Key key, this.pickedFile}) : super(key: key);

  @override
  _ProgressDialogState createState() => _ProgressDialogState();
}

class _ProgressDialogState extends State<ProgressDialog> {
  Subscription _subscription;

  double _progress = 0;

  @override
  void initState() {
    _startCompressing();
    super.initState();
  }

  @override
  void dispose() {
    _subscription.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        title: Text(AppLocalizations.of(context).translate("compressing_video"), style: TextStyle(fontWeight: FontWeight.bold),),
        content: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularPercentIndicator(
                radius: 60.0,
                lineWidth: 5.0,
                percent: _progress.truncate() / 100,
                center: new Text("${_progress.truncate().toString()} %"),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: Theme.of(context).primaryColor,
              )
            ],
          ),
        ),
        actions: <Widget>[],
      ),
    );
  }

  // Compress video
  void _startCompressing() async {
    _subscription = VideoCompress.compressProgress$.subscribe((progress) {
      setState(() {
        _progress = progress;
      });
    });

    MediaInfo mediaInfo = await VideoCompress.compressVideo(
      widget.pickedFile.path,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false,
      includeAudio: true,
    );

    Navigator.pop(context, File(mediaInfo.path));
  }
}

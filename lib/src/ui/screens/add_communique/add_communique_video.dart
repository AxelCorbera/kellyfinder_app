import 'dart:io';

import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/app_styles.dart';
import 'package:app/src/utils/media/handle_video_dialog.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AddCommuniqueVideo extends StatefulWidget {
  final File video;
  final Function callback;

  const AddCommuniqueVideo({Key key, this.video, this.callback}) : super(key: key);

  @override
  _AddCommuniqueVideoState createState() => _AddCommuniqueVideoState();
}

class _AddCommuniqueVideoState extends State<AddCommuniqueVideo> {
  @override
  Widget build(BuildContext context) {
    if (widget.video != null) {
      return InkWell(
        onTap: () async {
          final result = await handleVideoDialog(context, duration: 5);

          if (result != null) {
            widget.callback(result);
          }
        },
        child: AddCommuniqueVideoPlayer(video: widget.video),
      );
    }
    return Column(
      children: <Widget>[
        SizedBox(height: 24),
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
                  final result = await handleVideoDialog(context, duration: 5);

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
           AppLocalizations.of(context).translate("addCommuniqueVideo"),
            style: TextStyle(color: AppStyles.lightGreyColor),
          ),
        ),
        SizedBox(height: 32),
      ],
    );
  }
}

class AddCommuniqueVideoPlayer extends StatefulWidget {
  final File video;

  const AddCommuniqueVideoPlayer({Key key, this.video}) : super(key: key);

  @override
  _AddCommuniqueVideoPlayerState createState() => _AddCommuniqueVideoPlayerState();
}

class _AddCommuniqueVideoPlayerState extends State<AddCommuniqueVideoPlayer> {
  VideoPlayerController _controller;

  @override
  void initState() {
    _controller = VideoPlayerController.file(widget.video)
      ..initialize().then((_) {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      ),
    );
  }
}

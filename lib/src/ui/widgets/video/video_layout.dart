import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoLayout extends StatefulWidget {
  final video;
  final Function callback;

  const VideoLayout({Key key, this.video, this.callback}) : super(key: key);

  @override
  _VideoLayoutState createState() => _VideoLayoutState();
}

class _VideoLayoutState extends State<VideoLayout> {
  VideoPlayerController _controller;

  double _opacity = 1;

  @override
  void initState() {
    super.initState();

    if (widget.video is String) {
      _controller = VideoPlayerController.network(
        widget.video,
      )..initialize().then((_) {
          setState(() {});
        });
    } else if (widget.video is File) {
      _controller = VideoPlayerController.file(
        widget.video,
      )..initialize().then((_) {
          setState(() {});
        });
    }

    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          if (_controller.value.isPlaying) {
            _controller.pause();
            _opacity = 1;
          } else {
            _controller.play();

            Future.delayed(
              Duration(seconds: 2),
              () {
                setState(() {
                  _opacity = 0;
                });
              },
            );
          }
        });
      },
      child: Container(
        constraints: BoxConstraints(
          maxHeight: 250,
          minWidth: MediaQuery.of(context).size.width,
        ),
        child: Stack(
          children: <Widget>[
            Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),
            Positioned(
              child: Center(
                child: AnimatedOpacity(
                  opacity: _opacity,
                  duration: Duration(milliseconds: 500),
                  child: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    color: Theme.of(context).accentColor,

                    size: 64,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                elevation: 4.0,
                color: Theme.of(context).accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(40)),
                ),
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  onTap: () {
                    widget.callback();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.close,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

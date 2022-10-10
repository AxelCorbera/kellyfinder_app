import 'package:app/src/model/municipality/communique.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CommuniqueListVideo extends StatefulWidget {
  final Communique communique;
  final Function callback;

  const CommuniqueListVideo({Key key, this.callback, this.communique}) : super(key: key);

  @override
  _CommuniqueListVideoState createState() => _CommuniqueListVideoState();
}

class _CommuniqueListVideoState extends State<CommuniqueListVideo> {
  VideoPlayerController _videoController;

  double _opacity = 1;

  @override
  void initState() {
    _videoController = VideoPlayerController.network(
      widget.communique.media,
    )..initialize().then((_) {
        setState(() {});
      });

    _videoController.setLooping(true);

    super.initState();
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          if (_videoController.value.isPlaying) {
            _videoController.pause();
            _opacity = 1;
          } else {
            _videoController.play();
            _opacity = 0;
          }
        });

        Future.delayed(Duration(seconds: 1), () {
          widget.callback();
        });
      },
      child: AspectRatio(
        aspectRatio: _videoController.value.aspectRatio,
        child: Container(
          color: Colors.black,
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            child: Stack(
              children: [
                VideoPlayer(_videoController),
                Positioned(
                  child: AnimatedOpacity(
                    opacity: _opacity,
                    duration: Duration(milliseconds: 500),
                    child: Center(
                      child: _centerIcon(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _centerIcon() {
    if (_videoController.value.isPlaying)
      return Icon(
        Icons.pause,
        color: Colors.white,
        size: 48,
      );
    else
      return Icon(
        Icons.play_circle_outline,
        color: Colors.white,
        size: 48,
      );
  }
}

import 'package:app/src/model/municipality/municipality.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MunicipalityVideo extends StatefulWidget {
  final Municipality municipality;

  MunicipalityVideo({this.municipality});

  @override
  _MunicipalityVideoState createState() => _MunicipalityVideoState();
}

class _MunicipalityVideoState extends State<MunicipalityVideo> {
  VideoPlayerController _videoController;

  @override
  void initState() {
    _videoController = VideoPlayerController.network(
      /*"https://www.w3schools.com/html/mov_bbb.mp4",*/
      widget.municipality.video
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () {
          if (_videoController.value.isPlaying)
            _videoController.pause();
          else
            _videoController.play();
        },
        child: AspectRatio(
          aspectRatio: _videoController.value.aspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            child: VideoPlayer(_videoController),
          ),
        ),
      ),
    );
  }
}
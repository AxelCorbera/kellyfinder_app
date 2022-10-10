import 'package:app/src/config/app_styles.dart';
import 'package:app/src/model/municipality/communique.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class CommuniqueListAudio extends StatefulWidget {
  final Communique communique;
  CommuniqueListAudio({this.communique});

  @override
  _CommuniqueListAudioState createState() => _CommuniqueListAudioState();
}

class _CommuniqueListAudioState extends State<CommuniqueListAudio> {
  final player = AudioPlayer();

  Future _future;

  Duration initDuration;

  @override
  void initState() {
    _future = _init();
    super.initState();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return Container(
              decoration: BoxDecoration(
                //color: Theme.of(context).primaryColorLight.withOpacity(0.5),
                color: AppStyles.bgMunicipalityDetails,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: <Widget>[
                      if (player.state != AudioPlayerState.PLAYING)
                        IconButton(
                          icon: Icon(Icons.play_arrow),
                          onPressed: () async {
                            await player.resume();

                            final seconds = await player.getDuration();

                            initDuration = Duration(milliseconds: seconds);

                            setState(() {});
                          },
                        ),
                      if (player.state == AudioPlayerState.PLAYING)
                        IconButton(
                          icon: Icon(Icons.pause),
                          onPressed: () async {
                            await player.pause();
                            setState(() {});
                          },
                        ),
                      Expanded(
                        child: StreamBuilder(
                          stream: player.onAudioPositionChanged,
                          builder: (BuildContext context,
                              AsyncSnapshot<Duration> snapshot) {
                            final data = snapshot.data?.inSeconds ?? 1;
                            final init = initDuration?.inSeconds ?? 1;

                            double value = data / init;

                            return Stack(
                              children: <Widget>[
                                LinearProgressIndicator(
                                  value: value,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    //Theme.of(context).primaryColor,
                                    Color(0xFFb4b8c1)
                                  ),
                                  //backgroundColor: Colors.grey,
                                  backgroundColor: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.5),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                    ],
                  ),
                  StreamBuilder(
                    stream: player.onAudioPositionChanged,
                    builder: (BuildContext context,
                        AsyncSnapshot<Duration> snapshot) {
                      final data = snapshot.data ?? Duration(seconds: 1);
                      final init = initDuration ?? Duration(seconds: 1);

                      Duration value = init - data;

                      return Padding(
                        padding: const EdgeInsets.only(left: 48, bottom: 16),
                        child: Text(
                          "${_printDuration(value)}",
                          style: TextStyle(color: AppStyles.lightGreyColor),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }
        }
        return FutureCircularIndicator();
      },
    );
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future _init() async {
    await player.setUrl(
      //"https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
        widget.communique.media
    );

    await player.setReleaseMode(ReleaseMode.STOP);

    try {
      player.onPlayerStateChanged.listen((event) {
        if (event == AudioPlayerState.COMPLETED) {
          setState(() {
            player.stop();
            player.seek(Duration(seconds: 0));
          });
        }
      });

      return true;
    } catch (e) {
      print(e);
    }
  }
}

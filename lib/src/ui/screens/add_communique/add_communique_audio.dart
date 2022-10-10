import 'dart:io';

import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/app_styles.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';

import 'package:path_provider/path_provider.dart';

class AddCommuniqueAudio extends StatefulWidget {
  final Function callback;

  AddCommuniqueAudio({this.callback});

  @override
  _AddCommuniqueAudioState createState() => _AddCommuniqueAudioState();
}

class _AddCommuniqueAudioState extends State<AddCommuniqueAudio> {
  Future future;

  Recording recording;
  FlutterAudioRecorder recorder;

  @override
  void initState() {
    future = initAudio();
    super.initState();
  }

  Future initAudio() async {
    try {
      final Directory temp = await getTemporaryDirectory();

      String customPath = '/flutter_audio_recorder_';

      String path = temp.path +
          customPath +
          DateTime.now().millisecondsSinceEpoch.toString();

      recorder = FlutterAudioRecorder(path, audioFormat: AudioFormat.WAV);
      await recorder.initialized;

      return true;
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    recorder.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            if (recorder.recording.status == RecordingStatus.Initialized)
              return Column(
                children: <Widget>[
                  SizedBox(height: 24),
                  Center(
                    child: ClipOval(
                      child: Material(
                        color: Theme.of(context)
                            .primaryColorLight
                            .withOpacity(0.5),
                        child: InkWell(
                          child: SizedBox(
                            width: 64,
                            height: 64,
                            child: Icon(Icons.audiotrack, size: 24),
                          ),
                          onTap: () async {
                            bool hasPermission =
                                await FlutterAudioRecorder.hasPermissions;

                            if (hasPermission) {
                              try {
                                await recorder.start();
                                recording = await recorder.current(channel: 0);

                                setState(() {});
                              } catch (e) {
                                print(e);
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      AppLocalizations.of(context).translate("threeMinuteAudio"),
                      style: TextStyle(color: AppStyles.lightGreyColor),
                    ),
                  ),
                ],
              );
            else if (recorder.recording.status == RecordingStatus.Recording) {
              return Column(
                children: <Widget>[
                  Center(
                    child: ClipOval(
                      child: Material(
                        color: Theme.of(context)
                            .primaryColorLight
                            .withOpacity(0.5),
                        child: SizedBox(
                          width: 64,
                          height: 64,
                          child: Icon(Icons.audiotrack, size: 24),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.stop),
                        onPressed: () async {
                          await recorder.stop();
                          setState(() {});

                          widget.callback(recording);
                        },
                      ),
                      SizedBox(width: 40),
                      IconButton(
                        icon: Icon(Icons.pause),
                        onPressed: () async {
                          await recorder.pause();
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ],
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: CommuniqueListAudio(path: recording.path),
            );
          }
        }
        return FutureCircularIndicator();
      },
    );
  }
}

class CommuniqueListAudio extends StatefulWidget {
  final String path;

  const CommuniqueListAudio({Key key, this.path}) : super(key: key);

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
                color: Theme.of(context).primaryColorLight.withOpacity(0.5),
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
                                    Theme.of(context).primaryColor,
                                  ),
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
      widget.path,
      isLocal: true,
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

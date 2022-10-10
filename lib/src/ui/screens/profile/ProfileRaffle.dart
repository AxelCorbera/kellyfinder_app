import 'dart:io';

import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/user.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/widgets/button/custom_button.dart';
import 'package:app/src/ui/widgets/button/custom_future_button.dart';
import 'package:app/src/ui/widgets/dialog/custom_dialog.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:share/share.dart';
import 'package:app/src/config/globals.dart' as globals;

class ProfileRaffle extends StatefulWidget {
  final String videoUrl;
  final String raffleCode;

  ProfileRaffle({this.videoUrl, this.raffleCode});

  @override
  _ProfileRaffleState createState() => _ProfileRaffleState();
}

class _ProfileRaffleState extends State<ProfileRaffle> {
  VideoPlayerController _videoController;
  double _opacity = 1;

  ScrollController _scrollController;
  double _offset;

  Future _futureShare;

  bool get _isShrink {
    return _scrollController.hasClients && _offset > (200 - kToolbarHeight);
  }

  @override
  void initState() {
    _videoController = VideoPlayerController.network(
      widget.videoUrl,
    )..initialize().then((_) {
        setState(() {});
      });

    _videoController.setLooping(true);
    _videoController.play();

    Future.delayed(
      Duration(seconds: 2),
          () {
        setState(() {
          _opacity = 0;
        });
      },
    );

    _offset = 0.0;

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _offset = _scrollController.offset;

          if (_isShrink) _videoController.pause();
        });
      });

    super.initState();
  }

  @override
  void dispose() {
    _videoController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(centerTitle:true,
            expandedHeight: 200.0,
            pinned: true,
            floating: false,
            iconTheme: IconThemeData(
              color: _isShrink
                  ? Theme.of(context).appBarTheme.iconTheme.color
                  : Theme.of(context).accentColor,
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  _videoController.value.initialized
                      ? _buildVideo()
                      : Container(),
                ],
              ),
            ),
          ),
          _buildContent()
        ],
      ),
    );
  }

  Future _checkRaffle() async {
    final result = await ApiProvider().performIsLotteryActive({"user_id": Provider.of<UserNotifier>(context, listen: false).user.id});

    if (result['is_active']){
      Share.share(AppLocalizations.of(context).translate("share_text")
          + AppLocalizations.of(context).translate("share_text_more_info")
          + ' '
          + globals.kellyFinderWeb
          + AppLocalizations.of(context).translate("share_text_code")
          + ' '
          + widget.raffleCode
          + AppLocalizations.of(context).translate("share_text_android")
          + ' '
          + globals.androidStore
          + AppLocalizations.of(context).translate("share_text_iphone")
          + ' '
          + globals.iosStore);
    }else{
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(
            title: AppLocalizations.of(context).translate("raffle_not_available"),
            hasCancel: false,
          );
        },
      );
    }
  }

  _buildVideo() {
    return Container(
        width: MediaQuery.of(context).size.width,
        //height: 200,
        child: InkWell(
            onTap: () {
              setState(() {
                if (_videoController.value.isPlaying) {
                  _videoController.pause();
                  _opacity = 1;
                } else {
                  _videoController.play();

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
            child: Stack(
              children: <Widget>[
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController.value.size?.width ?? 0,
                      height: _videoController.value.size?.height ?? 0,
                      child: VideoPlayer(_videoController),
                    ),
                  ),
                ),
                Positioned(
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: _opacity,
                      duration: Duration(milliseconds: 500),
                      child: Icon(
                        _videoController.value.isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        color: Theme.of(context).accentColor,
                        size: 64,
                      ),
                    ),
                  ),
                ),
              ],
            )
            ));
  }

  _buildContent() {
    return SliverToBoxAdapter(
      child: Column(
        children: <Widget>[
          SizedBox(height: 16.0,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
                AppLocalizations.of(context).translate("raffle_instructions")),
          ),
          SizedBox(
            height: 16.0,
          ),
          GestureDetector(
            onTap: (){
              _launchURL(globals.raffleRulesURL);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(AppLocalizations.of(context).translate("raffle_rules"), style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, decoration: TextDecoration.underline),),
                        SizedBox(height: 8.0),
                        if(Platform.isIOS) Text(AppLocalizations.of(context).translate("raffle_apple"), style: TextStyle(fontSize: 13.0),)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 24.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: DottedBorder(
              color: Color(0XFF908C8C),
              dashPattern: [4],
              strokeWidth: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context).translate("raffle_code"),
                        style: TextStyle(color: Color(0XFF908C8C)),
                      ),
                      SizedBox(
                        height: 4.0,
                      ),
                      Text(
                        widget.raffleCode,
                        style: TextStyle(fontSize: 30, color: Color(0XFF908C8C)),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 24.0,
          ),
          Center(
            child: CustomFutureButton(
              text: AppLocalizations.of(context).translate("share"),
              future: _futureShare,
              callback: () async {
                setState(() {
                  _futureShare = _checkRaffle();
                });
              },
            ),
          )
        ],
      ),
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

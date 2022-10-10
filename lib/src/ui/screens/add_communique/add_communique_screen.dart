import 'dart:io';

import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/app_styles.dart';
import 'package:app/src/config/sentence_case_text_formatter.dart';
import 'package:app/src/config/string_casing_extension.dart';
import 'package:app/src/model/municipality/municipality.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/screens/add_communique/add_communique_audio.dart';
import 'package:app/src/ui/screens/add_communique/add_communique_image.dart';
import 'package:app/src/ui/screens/add_communique/add_communique_video.dart';
import 'package:app/src/ui/widgets/dialog/custom_dialog.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddCommuniqueScreen extends StatefulWidget {
  final Municipality municipality;
  final int connectedUsers;
  final Function callback;

  AddCommuniqueScreen({this.municipality, this.connectedUsers, this.callback});

  @override
  _AddCommuniqueScreenState createState() => _AddCommuniqueScreenState();
}

class _AddCommuniqueScreenState extends State<AddCommuniqueScreen>
    with TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future futureAudio;

  TabController _controller;

  File _image;
  File _video;

  Recording _audio;

  int _currentIndex = 0;

  TextEditingController _descController;

  @override
  void initState() {
    _controller = TabController(length: 4, vsync: this);
    _controller.addListener((){
      setState(() {
        _currentIndex = _controller.index;
      });
    });

    _descController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: NestedScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          headerSliverBuilder: (context, _) {
            return [
              SliverAppBar(centerTitle:true,
                title: Text(
                  AppLocalizations.of(context).translate("addCommunique"),
                ),
                floating: false,
                primary: true,
                pinned: true,
                expandedHeight: 180.0,
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.check),
                    onPressed: () async {
                      var media;
                      String type;

                      if(_currentIndex == 0){
                        media = _image;
                        type = "image";
                      }else if(_currentIndex == 1){
                        type = "text";
                      }else if(_currentIndex == 2){
                        media = _audio;
                        type = "audio";
                      }else{
                        media = _video;
                        type = "video";
                      }

                      await _createCommunique(media, type);
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  background: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context).translate("connectedUsers"),
                        style: TextStyle(
                          color: Colors.black38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                       widget.connectedUsers.toString(),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                bottom: TabBar(
                  controller: _controller,
                  unselectedLabelColor: AppStyles.lightGreyColor,
                  labelColor: Theme.of(context).primaryColor,
                  tabs: [
                    Tab(text: AppLocalizations.of(context).translate("image")),
                    Tab(text: AppLocalizations.of(context).translate("text")),
                    Tab(text: AppLocalizations.of(context).translate("audio")),
                    Tab(text: AppLocalizations.of(context).translate("video")),
                  ],
                ),
              )
            ];
          },
          body: TabBarView(
            controller: _controller,
            children: [
              ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                  AddCommuniqueImage(
                    image: _image,
                    callback: (result) {
                      setState(() {
                        _image = result;
                      });
                    },
                  ),
                  Divider(color: AppStyles.lightGreyColor),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: TextField(
                      inputFormatters: [
                        SentenceCaseTextFormatter()
                      ],
                      controller: _descController,
                      minLines: 5,
                      maxLines: null,
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context).translate("description"),
                        filled: true,
                      ),
                    ),
                  ),
                ],
              ),
              ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: TextField(
                      inputFormatters: [
                        SentenceCaseTextFormatter()
                      ],
                      controller: _descController,
                      minLines: 5,
                      maxLines: null,
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context).translate("description"),
                        filled: true,
                      ),
                    ),
                  ),
                ],
              ),
              ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                  AddCommuniqueAudio(
                    callback: (Recording media){
                      _audio = media;
                    },
                  ),
                ],
              ),
              ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                  AddCommuniqueVideo(
                    video: _video,
                    callback: (result) {
                      setState(() {
                        _video = result;
                      });
                    },
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: TextField(
                      inputFormatters: [
                        SentenceCaseTextFormatter()
                      ],
                      controller: _descController,
                      minLines: 5,
                      maxLines: null,
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context).translate("description"),
                        filled: true,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _createCommunique(var media, String type) async {
    if(type != "text"){
      if(media == null){
        String error = "";

        if(type == "image"){
          error = AppLocalizations.of(context).translate("create_communique_image_missing");
        }

        if(type == "audio"){
          error = AppLocalizations.of(context).translate("create_communique_audio_missing");
        }

        if(type == "video"){
          error = AppLocalizations.of(context).translate("create_communique_video_missing");
        }

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialog(
              title: error,
              hasCancel: false,
            );
          },
        );

        return;
      }
    }

    if(_descController.text.trim().isEmpty && type == "text"){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(
            title: AppLocalizations.of(context).translate("create_communique_description_missing"),
            hasCancel: false,
          );
        },
      );

      return;
    }

    try{
      final result = await ApiProvider()
          .createCommunique({
        "description": _descController.text.trim(),
        "type": type
      }, Provider.of<UserNotifier>(context, listen: false)
          .appUser
          .municipality.id, media, type);

      print(result);

      if(widget.callback != null){
        widget.callback();
      }

      Navigator.pop(context);
    } catch (e) {
      catchErrors(e, _scaffoldKey);
    }
  }
}

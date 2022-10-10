import 'dart:io';

import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/municipality/municipality.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/icons/custom_icons.dart';
import 'package:app/src/ui/screens/add_municipality/add_municipality_report_screen.dart';
import 'package:app/src/ui/widgets/button/custom_button.dart';
import 'package:app/src/ui/widgets/button/custom_future_button.dart';
import 'package:app/src/ui/widgets/dialog/custom_dialog.dart';
import 'package:app/src/ui/widgets/video/video_layout.dart';
import 'package:app/src/utils/media/handle_video_dialog.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class AddMunicipalityPresentationScreen extends StatefulWidget {
  final bool isCreating;

  AddMunicipalityPresentationScreen({this.isCreating = false});

  @override
  _AddMunicipalityPresentationScreenState createState() =>
      _AddMunicipalityPresentationScreenState();
}

class _AddMunicipalityPresentationScreenState
    extends State<AddMunicipalityPresentationScreen> {
  dynamic _video;

  Future _futureVideo;

  @override
  void initState() {
    if(Provider.of<UserNotifier>(context, listen: false)
        .appUser
        .municipality.video != null){
      _video = Provider.of<UserNotifier>(context, listen: false)
          .appUser
          .municipality.video;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate("publishMunicipality"),
        ),
      ),
      body: _buildBody(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CustomFutureButton(
        text: AppLocalizations.of(context).translate("save"),
        //future: _validate(),
        future: _futureVideo,
        callback: (){
          setState(() {
            _futureVideo = _validate();
          });
        },
        //function: _validate,
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(
            AppLocalizations.of(context).translate("municipalityPresentation"),
            style: Theme.of(context).textTheme.subtitle1.copyWith(
                color: Theme.of(context).primaryColorLight,
                fontWeight: FontWeight.w600),
          ),
          trailing: IconButton(
            icon: Icon(Icons.info),
            color: Theme.of(context).primaryColor,
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Text(
                              AppLocalizations.of(context).translate("publish_municipality_presentation_text_1")
                            ),
                            SizedBox(height: 16.0,),
                            Text(
                                AppLocalizations.of(context).translate("publish_municipality_presentation_text_2")
                            ),
                            SizedBox(height: 16.0,),
                            Text(
                                AppLocalizations.of(context).translate("publish_municipality_presentation_text_3")
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        SimpleDialogOption(
                          child: Text(
                            AppLocalizations.of(context)
                                .translate("close")
                                .toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  });
            },
          ),
        ),
        if (_video != null)
          VideoLayout(
            video: _video,
            callback: () {
              setState(() {
                _video = null;
              });
            },
          ),
        if (_video == null)
          ListTile(
            onTap: () async {
              File video = await handleVideoDialog(context, duration: 3);

              print("VIDEO: $video");
              if (video != null) {
                VideoPlayerController controller = new VideoPlayerController.file(video);
                await controller.initialize();

                if(controller.value.duration.inSeconds > 180){
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomDialog(
                        title: AppLocalizations.of(context).translate("municipality_video_limit_exceeded"),
                        hasCancel: false,
                      );
                    },
                  );

                  return;
                }

                setState(() {
                  _video = video;
                });
              }
            },
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            title: Center(
              child: CircleAvatar(
                radius: 30,
                backgroundColor:
                    Theme.of(context).primaryColorLight.withOpacity(0.5),
                child: Icon(
                  CustomIcons.video,
                  color: Theme.of(context).primaryColor,
                  size: 36,
                ),
              ),
            ),
            subtitle: Container(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                AppLocalizations.of(context).translate("municipalityVideo"),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Future _validate() async {

    Municipality municipality =
        Provider.of<UserNotifier>(context, listen: false).appUser.municipality;

    final result = await ApiProvider().createMunicipality({
      "id": municipality.id,
    }, [], _video);

    Municipality newMunicipality = Municipality.fromJson(result);

    // Guardar municipio en AppUser
    Provider.of<UserNotifier>(context, listen: false)
        .setUserMunicipality(newMunicipality);

    if (/*municipality == null*/widget.isCreating) {
      navigateTo(context, AddMunicipalityReport(isCreating: widget.isCreating,));
    } else {
      Navigator.pop(context);
    }
  }
}

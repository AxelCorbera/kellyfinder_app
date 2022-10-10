import 'dart:io';

import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/municipality/image.dart';
import 'package:app/src/model/municipality/municipality.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/screens/add_municipality/add_municipality_visits_screen.dart';
import 'package:app/src/ui/widgets/button/custom_button.dart';
import 'package:app/src/ui/widgets/dialog/custom_dialog.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/api/api_exception.dart';
import 'package:app/src/utils/media/handle_image_dialog.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddMunicipalityReport extends StatefulWidget {
  final bool isCreating;

  AddMunicipalityReport({this.isCreating = false});

  @override
  _AddMunicipalityReportState createState() => _AddMunicipalityReportState();
}

class _AddMunicipalityReportState extends State<AddMunicipalityReport> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<MunicipalityImage> _muniPics;

  Future _futureImages;

  bool _isLoading = false;
  int _indexLoading;

  @override
  void initState() {
    super.initState();

    _futureImages = getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate("publishMunicipality"),
        ),
      ),
      body: FutureBuilder(
        future: _futureImages,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return _buildBody();
            }
          }
          return FutureCircularIndicator();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CustomButton(
        text: widget.isCreating ? AppLocalizations.of(context).translate("next") : AppLocalizations.of(context).translate("municipality_graphic_report_back"),
        function: () {
          if (/*municipality == null*/widget.isCreating) {
            navigateTo(context, AddMunicipalityVisitsScreen(isCreating: widget.isCreating,));
          } else {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: <Widget>[
        ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate("graphicReport"),
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                    color: Theme.of(context).primaryColorLight,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4.0,),
              Text(
                AppLocalizations.of(context).translate("municipality_graphic_report_delete_tip"),
                style: Theme.of(context).textTheme.subtitle2,
              )
            ],
          ),
        ),
        SizedBox(height: 8.0,),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: 15,
          padding: EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (BuildContext context, int index) {
            File image;
            MunicipalityImage _municipalityImage;

            if (index < _muniPics.length) {
              _municipalityImage = _muniPics[index];
            }

            return InkWell(
              onLongPress: () async {
                final result = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomDialog(
                      title: AppLocalizations.of(context).translate("municipality_graphic_report_delete_confirmation_text"),
                      buttonText: AppLocalizations.of(context).translate("accept"),
                    );
                  },
                );

                if(result){
                  if (_muniPics[index].pic is String){
                    await _deleteImage(_muniPics[index]);
                  }

                  setState(() {
                    _muniPics.removeAt(index);
                  });
                }
              },
              onTap: () async {
                if (!_isLoading) {
                  final result = await handleImageDialog(context);

                  if (result != null) {
                    // Comprobamos si ya había imagen en el slot, si no la añadimos
                    if (_municipalityImage != null) {
                      setState(() {
                        _indexLoading = index;
                      });

                      if (_muniPics[index].pic is String){
                        await _deleteImage(_muniPics[index]);
                      }

                      setState(() {
                        _muniPics[index] = MunicipalityImage(pic: result);
                      });
                    } else {
                      setState(() {
                        _indexLoading = index;
                      });

                      setState(() {
                        _muniPics.add(MunicipalityImage(pic: result));
                      });
                    }

                    await _createImage(_muniPics[index]);
                  }
                }
              },
              child: Stack(
                fit: StackFit.expand,
                children: [_setImage(_municipalityImage), _checkLoading(index)],
              ),
            );
          },
        ),
      ],
    );
  }

  Future getData() async {
    try {
      _muniPics = await ApiProvider().getMunicipalityPics({}, Provider.of<UserNotifier>(context, listen: false)
          .appUser
          .municipality.id);

      return true;
    } catch (e) {
      catchErrors(e, _scaffoldKey);
    }
  }

  Widget _setImage(MunicipalityImage municipalityImage) {
    if (municipalityImage?.pic is File) {
      return Image.file(municipalityImage.pic, fit: BoxFit.cover);
    } else if (municipalityImage?.pic is String) {
      return Image.network(municipalityImage.pic, fit: BoxFit.cover);
    } else {
      return Container(
        color: Theme.of(context).disabledColor,
        child: Icon(
          Icons.add_a_photo,
          color: Theme.of(context).primaryColorLight,
        ),
      );
    }
  }

  Future _createImage(MunicipalityImage municipalityImage) async {
    setState(() {
      _isLoading = true;
    });

    try {
      var result = await ApiProvider()
          .createMunicipalityPic({}, [municipalityImage.pic], Provider.of<UserNotifier>(context, listen: false)
          .appUser
          .municipality.id);

      print(result);

      await getData();

      return true;
    } catch (e) {
      catchErrors(e, _scaffoldKey);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _deleteImage(MunicipalityImage municipalityImage) async {
    try {
      var result =
          await ApiProvider().deleteMunicipalityPic({}, municipalityImage.id);

      print(result);
    } catch (e) {
      catchErrors(e, _scaffoldKey);
    }
  }

  _checkLoading(int index) {
    if (_isLoading && index == _indexLoading) {
      return FutureCircularIndicator();
    } else {
      return Container();
    }
  }
}

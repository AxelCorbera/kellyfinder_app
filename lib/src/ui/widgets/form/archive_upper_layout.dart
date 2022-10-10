import 'dart:io';

import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/globals.dart' as globals;
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/model/category.dart';
import 'package:app/src/model/industrial_park/industrial_park_category.dart';
import 'package:app/src/provider/category_notifier.dart';
import 'package:app/src/ui/icons/custom_icons.dart';
import 'package:app/src/ui/widgets/dialog/custom_dialog.dart';
import 'package:app/src/ui/widgets/image/file_profile_image.dart';
import 'package:app/src/ui/widgets/image/network_profile_image.dart';
import 'package:app/src/ui/widgets/video/video_layout.dart';
import 'package:app/src/utils/media/handle_image_dialog.dart';
import 'package:app/src/utils/media/handle_video_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:app/src/config/string_casing_extension.dart';

class ArchiveUpperLayout extends StatefulWidget {
  final List images;
  final video;
  final Function selectVideo;
  final Function deleteVideo;
  final String text;
  final Category industrialParkCategory;
  final int videoDuration;

  const ArchiveUpperLayout(
      {Key key,
      this.images,
      this.selectVideo,
      this.video,
      this.deleteVideo,
      this.text = "",
      this.industrialParkCategory,
      this.videoDuration = 1})
      : super(key: key);

  @override
  _ArchiveUpperLayoutState createState() => _ArchiveUpperLayoutState();
}

class _ArchiveUpperLayoutState extends State<ArchiveUpperLayout> {
  @override
  Widget build(BuildContext context) {
    int selectedImages = 0;

    widget.images.forEach((element) {
      if (element != null) selectedImages++;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          title: Text(
            getCatText().toSentenceCase(),
            textAlign: TextAlign.center,
            maxLines: null,
          ),
        ),
        Divider(height: 1),
        if (widget.video != null)
          VideoLayout(
            video: widget.video,
            callback: widget.deleteVideo,
          ),
        if (widget.video == null)
          ListTile(
            onTap: () async {
              File video = await handleVideoDialog(context, duration: widget.videoDuration);

              setState(() {});

              if (video != null) {
                VideoPlayerController controller = new VideoPlayerController.file(video);
                await controller.initialize();

                if(controller.value.duration.inSeconds > (widget.videoDuration * 60)){
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomDialog(
                        title: AppLocalizations.of(context).translate("archive_video_limit_exceeded"),
                        hasCancel: false,
                      );
                    },
                  );

                  return;
                }

                widget.selectVideo(video);
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
              _getVideoText().toSentenceCase(),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        Divider(
          height: 1,
        ),
        ListTile(
          title: Text(
            AppLocalizations.of(context).translate("addImages"),
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          trailing: Text("$selectedImages/4"),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 12,
            children: [0, 1, 2, 3]
                .map((item) {
                  if (widget.images[item] == null)
                    return Material(
                      elevation: 4,
                      color: Theme.of(context).disabledColor,
                      clipBehavior: Clip.hardEdge,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      child: InkWell(
                        onTap: () async {
                          File image = await handleImageDialog(context);

                          if (image != null) {
                            setState(() {
                              widget.images[item] = image;
                            });
                          }
                        },
                        child: Container(
                          height: 60,
                          width: 60,
                          child: Icon(
                            CustomIcons.add_pic,
                            size: 20,
                          ),
                        ),
                      ),
                    );

                  if (widget.images[item] is File)
                    return FileProfileImage(
                      image: widget.images[item],
                      height: 60,
                      width: 60,
                      function: () async {
                        File image = await handleImageDialog(context);

                        if (image != null) {
                          setState(() {
                            widget.images[item] = image;
                          });
                        }
                      },
                    );

                  return NetworkProfileImage(
                    image: widget.images[item],
                    height: 60,
                    width: 60,
                    function: () async {
                      File image = await handleImageDialog(context);

                      if (image != null) {
                        setState(() {
                          widget.images[item] = image;
                        });
                      }
                    },
                  );
                })
                .toList()
                .cast<Widget>(),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  String getArchiveText() {
    if (globals.archiveType == Offer) {
      return AppLocalizations.of(context).translate("textOffer");
    } else if (globals.archiveType == Demand) {
      return AppLocalizations.of(context).translate("textDemand");
    } else {
      return AppLocalizations.of(context).translate("textCompany");
    }
  }

  String getCatText() {
    Category category =
        Provider.of<CategoryNotifier>(context, listen: false).selectedCategory;

    Category subcategory = Provider.of<CategoryNotifier>(context, listen: false)
        .selectedSubcategory;

    /*print("TEXT SELECTED CATEGORY: ${category.name}");
    print("TEXT SELECTED SUBCATEGORY: ${subcategory.name}");*/

    print("CATEGORY upper layout: ${category.type}");

    if (globals.archiveType == Company) {
      if (category.type != "24h") {
        if (subcategory?.advertiseCat != null ?? false) {
          if (subcategory.advertiseCat.id == category.id) {
            return widget.text + "${category.name}";
          } else{
            /*if(widget.industrialParkCategory != null){
              return widget.text +
                  "${category.name}${subcategory != null ? subcategory.hasAdvertiseParent : ""} - ${widget.industrialParkCategory.name}";
            }*/

            return widget.text +
                "${category.name}${subcategory != null ? subcategory.hasAdvertiseParent : ""}";
          }
        } else {
          return widget.text + "${category.name}";
        }
      } else {
        return widget.text +
            "${category.name}${subcategory != null ? subcategory.hasParent : ""}";
      }
    } else {
      return widget.text +
          "${category.name}${subcategory != null ? subcategory.hasParent : ""}";
    }
  }

  String _getVideoText() {
    Category category =
        Provider.of<CategoryNotifier>(context, listen: false).selectedCategory;

    String str = "";

    if(widget.videoDuration == 1){
      str = "${AppLocalizations.of(context).translate("add1MinuteVideo")} ${getArchiveText()} ${AppLocalizations.of(context).translate("moreViews")}";
    }else if(widget.videoDuration == 2){
      if(category.type != "shared"){
        str = "${AppLocalizations.of(context).translate("add2MinuteVideo")} ${getArchiveText()} ${AppLocalizations.of(context).translate("moreViews")}";
      }else{
        str = "${AppLocalizations.of(context).translate("textSharedVideo")}";
      }
    }else{
      str = "${AppLocalizations.of(context).translate("add3MinuteVideo")} ${getArchiveText()} ${AppLocalizations.of(context).translate("moreViews")}";
    }


    return str;
  }
}

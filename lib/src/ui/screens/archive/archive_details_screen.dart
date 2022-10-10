import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/model/category.dart';
import 'package:app/src/model/chat/chat.dart';
import 'package:app/src/model/user.dart';
import 'package:app/src/provider/category_notifier.dart';
import 'package:app/src/provider/chat_notifier.dart';
import 'package:app/src/provider/socket_notifier.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/screens/archive/archive_image_screen.dart';
import 'package:app/src/ui/screens/archive/report_screen.dart';
import 'package:app/src/ui/screens/chat/chat_screen.dart';
import 'package:app/src/ui/widgets/button/custom_button.dart';
import 'package:app/src/ui/widgets/dialog/custom_dialog.dart';
import 'package:app/src/ui/widgets/icon/custom_like_button.dart';
import 'package:app/src/ui/widgets/image/network_profile_image.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/methods/launch_location.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:app/src/config/string_casing_extension.dart';
import 'package:app/src/ui/screens/municipality_details/municipality_images_screen.dart';

class ArchiveDetailsScreen extends StatefulWidget {
  final Archive archive;

  const ArchiveDetailsScreen({Key key, this.archive}) : super(key: key);

  @override
  _GroupDetailsScreenState createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<ArchiveDetailsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  ScrollController _scrollController;

  double _offset;

  VideoPlayerController _videoController;

  double _opacity = 1;

  bool _likeLoading = false;

  @override
  void initState() {
    super.initState();

    _offset = 0.0;

    _videoController = VideoPlayerController.network(widget.archive.video)
      ..initialize().then((_) {
        setState(() {});
      });

    _videoController.setLooping(true);

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _offset = _scrollController.offset;

          if (_isShrink) _videoController.pause();
        });
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  bool get _isShrink {
    return _scrollController.hasClients && _offset > (200 - kToolbarHeight);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: _buildAppBar(),
      floatingActionButton: widget.archive is Company ||
              widget.archive.user.id ==
                  Provider.of<UserNotifier>(context, listen: false).user.id
          ? null
          : CustomButton(
              text: AppLocalizations.of(context).translate("message"),
              function: () async {

                bool hasBlocked = await ApiProvider().hasBlocked({
                  "user_id": widget.archive.user.id
                });

                if(!hasBlocked){
                  try {
                    Chat chat = await ApiProvider().performCreateRoom({
                      "user_id": widget.archive.user.id,
                      "type": widget.archive is Offer ? "offer" : "demand"
                    });

                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ChatScreen(chat: chat);
                        },
                      ),
                    );

                    Provider.of<UserNotifier>(context, listen: false)
                        .initUserSocket(context);

                    try {
                      ApiProvider().performHasNewNotifications({}).then((result) {
                        bool hasNewNotifications = result["has_new_requests"];
                        bool hasNewChats = result["has_new_chats"];

                        if (hasNewNotifications)
                          Provider.of<SocketNotifier>(context, listen: false)
                              .addNewNotification();

                        Provider.of<SocketNotifier>(context, listen: false)
                            .addNewChat(hasNewChats);

                        User _user =
                            Provider.of<UserNotifier>(context, listen: false)
                                .user;

                        //if (hasNewChats)
                        Provider.of<ChatNotifier>(context, listen: false)
                            .updateUserChats(_user);
                      });
                    } catch (e) {
                      print(e);
                    }
                  } catch (e) {
                    catchErrors(e, _scaffoldKey);
                  }
                }else{
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomDialog(
                        title: AppLocalizations.of(context).translate("chat_blocked"),
                        hasCancel: false,
                      );
                    },
                  );
                }
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAppBar() {
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            centerTitle: true,
            expandedHeight: 220.0,
            pinned: true,
            floating: false,
            actions: <Widget>[
              if (widget.archive.user.id !=
                  Provider.of<UserNotifier>(context, listen: false).user.id)
                PopupMenuButton<int>(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 1,
                      height: 32,
                      child: Text(
                        AppLocalizations.of(context).translate("report"),
                      ),
                    ),
                  ],
                  icon: Icon(
                    Icons.more_vert,
                    color: _isShrink
                        ? Theme.of(context).appBarTheme.iconTheme.color
                        : Theme.of(context).accentColor,
                  ),
                  offset: Offset(0, 20),
                  onSelected: (value) {
                    navigateTo(context, ReportScreen(archive: widget.archive));
                  },
                ),
            ],
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
                  if (widget.archive is! Company)
                    Positioned(
                      right: 20,
                      bottom: 8,
                      child: Material(
                        elevation: 4.0,
                        color: Theme.of(context).disabledColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(60)),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: InkWell(
                          onTap: () =>
                              _onLikeButtonTapped(widget.archive.isFavorite),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(10, 10, 7, 7),
                            child: Container(
                              width: 30,
                              height: 30,
                              child: CustomLikeButton(
                                callback: _onLikeButtonTapped,
                                isLiked: widget.archive.isFavorite,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ];
      },
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(0),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: widget.archive.images
                    .map((item) {
                      return NetworkProfileImage(
                        image: item.pic,
                        width: 64,
                        height: 64,
                        function: () => navigateTo(
                            context, ArchiveImageScreen(image: item.pic, images: widget.archive.images,)),
                      );
                    })
                    .toList()
                    .cast<Widget>(),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                widget.archive.name,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2
                          .copyWith(fontSize: 16),
                    ),
                  ),
                  Text(
                    //"${AppLocalizations.of(context).translate("to")} ${widget.archive.distanceAsString}",
                    widget.archive.distance != null ?
                    "${AppLocalizations.of(context).translate("to")} ${widget.archive.distanceAsString}" :
                    "",
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(color: Theme.of(context).primaryColorLight),
                  ),
                ],
              ),
            ),
            if (widget.archive is Company)
              _buildCompany(widget.archive)
            else if (widget.archive is Offer)
              _buildOffer(widget.archive)
            else
              _buildDemand(widget.archive)
          ],
        ),
      ],
    );
  }

  Widget _buildCompany(Company company) {
    Category category =
        Provider.of<CategoryNotifier>(context, listen: false).selectedCategory;

    if (category == null) category = widget.archive.category.getParent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          title: Text(
            AppLocalizations.of(context).translate("companyDescription"),
            style: Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 16),
          ),
          subtitle: Container(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              company.desc.toSentenceCase(),
              textAlign: TextAlign.justify,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              InkWell(
                onTap: () {
                  launchLocation(company.lat, company.long);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.location_on),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        company.direction,
                        style: Theme.of(context).textTheme.caption,
                        maxLines: null,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              InkWell(
                onTap: () {
                  if(company.web != "" && company.web != null)
                    launchWeb(company.web);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.language),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        (company.web != "" && company.web!=null? company.web : "-"),
                        style: Theme.of(context).textTheme.caption,
                        maxLines: null,
                      ),
                    ),
                  ],
                ),
              ),
              if (category.type == "hostelry") SizedBox(height: 12),
              if (category.type == "hostelry")
                Wrap(
                  spacing: 4,
                  children: <Widget>[
                    Icon(Icons.check),
                    Text(
                      company.safeText(context),
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
            ],
          ),
        ),
        ListTile(
          title: Text(
            category.type != "shared"
                ? AppLocalizations.of(context)
                    .translate("recommendationsObservations")
                : category.sharedText(context),
            style: Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 16),
          ),
          subtitle: Container(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
                company.recommendations.toSentenceCase()
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOffer(Offer offer) {
    Category category =
        Provider.of<CategoryNotifier>(context, listen: false).selectedCategory;

    if (category == null) category = widget.archive.category.getParent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          title: Text(
            AppLocalizations.of(context).translate("offerDescription"),
            style: Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 16),
          ),
          subtitle: Container(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              offer.desc.toSentenceCase(),
              textAlign: TextAlign.justify,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Wrap(
            direction: Axis.vertical,
            spacing: 12,
            children: <Widget>[
              if (category.type != "shared")
                if (offer.hasReferences)
                  Wrap(
                    spacing: 4,
                    children: <Widget>[
                      Icon(Icons.check_box),
                      Text(
                        AppLocalizations.of(context).translate("references"),
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
              Wrap(
                spacing: 4,
                children: <Widget>[
                  Icon(Icons.location_on),
                  Text(
                    widget.archive.locality,
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
              if (category.type != "shared")
                Wrap(
                  spacing: 4,
                  children: <Widget>[
                    Text(
                        "${AppLocalizations.of(context).translate("nationality")}:"),
                    Text(
                        offer.nationality.toSentenceCase(),
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (category.type != "shared")
          ListTile(
            title: Text(
              AppLocalizations.of(context).translate("requisites"),
              style:
                  Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 16),
            ),
            subtitle: Container(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Text(
    offer.requisites.toSentenceCase(),
                textAlign: TextAlign.justify,
              ),
            ),
          ),
        ListTile(
          title: Text(
            category.type != "shared"
                ? AppLocalizations.of(context)
                    .translate("observationsConditions")
                : category.sharedText(context),
            style: Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 16),
          ),
          subtitle: Container(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
    offer.observations.toSentenceCase(),
              textAlign: TextAlign.justify,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDemand(Demand demand) {
    Category category =
        Provider.of<CategoryNotifier>(context, listen: false).selectedCategory;

    if (category == null) category = widget.archive.category.getParent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          title: Text(
            AppLocalizations.of(context).translate("demandDescription"),
            style: Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 16),
          ),
          subtitle: Container(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              demand.desc.toSentenceCase(),
              textAlign: TextAlign.justify,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Wrap(
            direction: Axis.vertical,
            spacing: 12,
            children: <Widget>[
              if (category?.type != "shared")
                if (demand.hasReferences)
                  Wrap(
                    spacing: 4,
                    children: <Widget>[
                      Icon(Icons.check_box),
                      Text(
                        AppLocalizations.of(context).translate("references"),
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
              Wrap(
                spacing: 4,
                children: <Widget>[
                  Icon(Icons.location_on),
                  Text(
                  widget.archive.locality,
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
              if (category?.type != "shared")
                Wrap(
                  spacing: 4,
                  children: <Widget>[
                    Text(
                        "${AppLocalizations.of(context).translate("nationality")}:"),
                    Text(
    demand.nationality,
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (category?.type != "shared")
          ListTile(
            title: Text(
              AppLocalizations.of(context).translate("formation"),
              style:
                  Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 16),
            ),
            subtitle: Container(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Text(
                demand.formation,
                textAlign: TextAlign.justify,
              ),
            ),
          ),
        if (category?.type != "shared")
          ListTile(
            title: Text(
              AppLocalizations.of(context).translate("experience"),
              style:
                  Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 16),
            ),
            subtitle: Container(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Text(
                demand.experience,
                textAlign: TextAlign.justify,
              ),
            ),
          ),
        ListTile(
          title: Text(
            category?.type != "shared"
                ? AppLocalizations.of(context)
                    .translate("observationsConditions")
                : category.sharedText(context),
            style: Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 16),
          ),
          subtitle: Container(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
    demand.observations.toSentenceCase(),
              textAlign: TextAlign.justify,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideo() {
    return Container(
      padding: widget.archive is! Company ? EdgeInsets.only(bottom: 24) : null,
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
        ),
      ),
    );
  }

  Future<bool> _onLikeButtonTapped(bool isLiked) async {
    if (!_likeLoading)
      try {
        Map result;

        setState(() {
          _likeLoading = true;
        });

        if (isLiked)
          result = await ApiProvider()
              .performUnMarkCardAsFavorite({"card_id": widget.archive.id});
        else
          result = await ApiProvider()
              .performMarkCardAsFavorite({"card_id": widget.archive.id});

        widget.archive.isFavorite =
            result["is_favorite_card"] == 1 ? true : false;

        setState(() {
          _likeLoading = false;
        });

        return widget.archive.isFavorite;
      } catch (e) {
        setState(() {
          _likeLoading = false;
        });
        return isLiked;
      }
  }
}

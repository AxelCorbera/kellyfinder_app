import 'dart:io';

import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/sentence_case_text_formatter.dart';
import 'package:app/src/config/sentence_words_text_formatter.dart';
import 'package:app/src/config/string_casing_extension.dart';
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/model/category.dart';
import 'package:app/src/model/user.dart';
import 'package:app/src/provider/category_notifier.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/screens/add_archive/archive_selection_screen.dart';
import 'package:app/src/ui/widgets/button/custom_future_button.dart';
import 'package:app/src/ui/widgets/dialog/custom_dialog.dart';
import 'package:app/src/ui/widgets/form/archive_upper_layout.dart';
import 'package:app/src/ui/widgets/form/location_textfield.dart';
import 'package:app/src/ui/widgets/navigation_bar.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/form/form_exception.dart';
import 'package:app/src/utils/form/form_validate.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ArchiveOfferScreen extends StatefulWidget {
  final Offer offer;

  const ArchiveOfferScreen({Key key, this.offer}) : super(key: key);

  @override
  _ArchiveOfferScreenState createState() => _ArchiveOfferScreenState();
}

class _ArchiveOfferScreenState extends State<ArchiveOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _nameController;
  TextEditingController _locationController;
  TextEditingController _nationalityController;
  TextEditingController _offerController;
  TextEditingController _requisitesController;
  TextEditingController _observationsController;

  FocusNode _nationalityNode;
  FocusNode _offerNode;
  FocusNode _requisitesNode;
  FocusNode _observationsNode;

  bool _highlight;
  bool _references;

  List _images;

  var _video;

  Map _mapInfo;

  Future _futureAdd;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    Offer offer = widget.offer;

    Category category =
        Provider.of<CategoryNotifier>(context, listen: false).selectedCategory;

    if(category.type != "shared"){
      Future.delayed(Duration.zero, (){
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialog(
              title: AppLocalizations.of(context).translate("create_offer_popup_text"),
              hasCancel: false,
            );
          },
        );
      });
    }

    _nameController = TextEditingController(text: offer?.name);

    // Si está creando de 0, ponemos el nombre del usuario
    if(offer == null){
      Future.delayed(Duration.zero, (){
        setState(() {
          _nameController = TextEditingController(text: Provider.of<UserNotifier>(context, listen: false).user.name);
        });
      });
    }

    _locationController = TextEditingController();
    _nationalityController = TextEditingController(text: offer?.nationality);
    _offerController = TextEditingController(
      text: category.type != "shared" ? offer?.desc : offer?.observations,
    );
    _requisitesController = TextEditingController(text: offer?.requisites);
    _observationsController = TextEditingController(
      text: category.type != "shared" ? offer?.observations : offer?.desc,
    );

    _video = offer?.video;

    _nationalityNode = FocusNode();
    _offerNode = FocusNode();
    _requisitesNode = FocusNode();
    _observationsNode = FocusNode();

    _highlight = offer?.isHighlight ?? false;
    _references = offer?.hasReferences ?? false;

    _images = [];

    for (int i = 0; i < 4; i++) {
      int length = offer?.images?.length ?? 0;

      if (i < length) {
        _images.add(offer.images[i].pic);
      } else {
        _images.add(null);
      }
    }

    User user = Provider.of<UserNotifier>(context, listen: false).user;

    if (offer != null) {
      _mapInfo = {
        "lat": offer.lat,
        "long": offer.long,
        "city": offer.locality,
      };

      _locationController.text = offer.locality;
    } else if (user.lat != null && user.long != null) {
      _mapInfo = {
        "lat": user.lat,
        "long": user.long,
        "city": user.locality,
      };

      _locationController.text = user.locality;
      //_mapInfo = {};
    } else {
      _mapInfo = {};
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _nationalityController.dispose();
    _offerController.dispose();
    _requisitesController.dispose();
    _observationsController.dispose();

    _nationalityNode.dispose();
    _offerNode.dispose();
    _requisitesNode.dispose();
    _observationsNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(centerTitle:true,
        title: Text(AppLocalizations.of(context).translate("offer")),
        actions: <Widget>[
          if (widget.offer != null)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteCard,
            ),
        ],
        bottom: PreferredSize(
          child: FutureBuilder(
            future: _futureAdd,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: 4,
                  child: LinearProgressIndicator(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                );
              }
              return Container(height: 4);
            },
          ),
          preferredSize: Size.fromHeight(4),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Form(
                key: _formKey,
                child: _buildForm(context),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    Category category =
        Provider.of<CategoryNotifier>(context, listen: false).selectedCategory;

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ArchiveUpperLayout(
          images: _images,
          video: _video,
          selectVideo: (File video) {
            setState(() {
              _video = video;
            });
          },
          deleteVideo: () {
            setState(() {
              _video = null;
            });
          },
          videoDuration: 2,
        ),
        if (category.type != "shared")
          CheckboxListTile(
            activeColor: Theme.of(context).buttonColor,
            value: _highlight,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (value) {
              setState(() {
                _highlight = !_highlight;
              });
            },
            title: Text(
              AppLocalizations.of(context).translate("highlightArchive"),
            ),
            subtitle: _highlight
                ? Text(
                    AppLocalizations.of(context).translate("payOption"),
                  )
                : null,
          ),
        if (category.type == "social")
          CheckboxListTile(
            activeColor: Theme.of(context).buttonColor,
            value: _references,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (value) {
              setState(() {
                _references = !_references;
              });
            },
            title: Text(
              AppLocalizations.of(context).translate("references"),
            ),
          ),
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: TextFormField(
            controller: _nameController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            maxLines: null,
            inputFormatters: [
              LengthLimitingTextInputFormatter(190),
              FilteringTextInputFormatter.deny(RegExp("[0-9]")),
              SentenceWordsTextFormatter()
            ],
            decoration: InputDecoration(
              labelText: category.type != "shared"
                  ? AppLocalizations.of(context).translate("fullName")
                  : AppLocalizations.of(context).translate("nameSurname"),
              fillColor: Theme.of(context).disabledColor,
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: (value) => validateEmpty(value, context),
            onFieldSubmitted: (value) => category.type != "shared"
                ? _nationalityNode.requestFocus()
                : _offerNode.requestFocus(),
          ),
        ),
        LocationTextField(
          controller: _locationController,
          mapInfo: _mapInfo,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          callback: (address) {
            setState(() {
              _locationController.text = address;
            });
          },
        ),
        if (category.type != "shared")
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: TextFormField(
              inputFormatters: [
                SentenceWordsTextFormatter()
              ],
              controller: _nationalityController,
              focusNode: _nationalityNode,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              maxLines: null,
              decoration: InputDecoration(
                labelText:
                    AppLocalizations.of(context).translate("nationality"),
                fillColor: Theme.of(context).disabledColor,
                filled: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              validator: (value) => validateEmpty(value, context),
              onFieldSubmitted: (value) => _offerNode.requestFocus(),
            ),
          ),
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: TextFormField(
            inputFormatters: [
              SentenceCaseTextFormatter()
            ],
            controller: _offerController,
            focusNode: _offerNode,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            maxLines: null,
            decoration: InputDecoration(
              labelText: category.type != "shared"
                  ? AppLocalizations.of(context).translate("offer")
                  : category.sharedText(context),
              fillColor: Theme.of(context).disabledColor,
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: (value) => validateEmpty(value, context),
            onFieldSubmitted: (value) => category.type != "shared"
                ? _requisitesNode.requestFocus()
                : _observationsNode.requestFocus(),
          ),
        ),
        if (category.type != "shared")
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: TextFormField(
              inputFormatters: [
                SentenceCaseTextFormatter()
              ],
              controller: _requisitesController,
              focusNode: _requisitesNode,
              //keyboardType: TextInputType.text,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              minLines: 5,
              maxLines: null,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).translate("requisites"),
                alignLabelWithHint: true,
                fillColor: Theme.of(context).disabledColor,
                filled: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              validator: (value) => validateEmpty(value, context),
              //onFieldSubmitted: (value) => _observationsNode.requestFocus(),
            ),
          ),
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: TextFormField(
            inputFormatters: [
              SentenceCaseTextFormatter()
            ],
            controller: _observationsController,
            focusNode: _observationsNode,
            //keyboardType: TextInputType.text,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            minLines: 5,
            maxLines: null,
            decoration: InputDecoration(
              labelText: category.type != "shared"
                  ? AppLocalizations.of(context)
                      .translate("observationsConditions")
                  : AppLocalizations.of(context).translate("description"),
              alignLabelWithHint: true,
              fillColor: Theme.of(context).disabledColor,
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: (value) => validateEmpty(value, context),
          ),
        ),
        SizedBox(height: 32),
        Center(
          child: CustomFutureButton(
            text: AppLocalizations.of(context).translate("accept"),
            future: _futureAdd,
            callback: () {
              if (!_isLoading) {
                setState(() {
                  _isLoading = true;
                  _futureAdd = _validate();
                });
              }
            },
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Future _validate() async {
    if (_formKey.currentState.validate()) {


      if (_video != null) {
        bool hasImages = false;

        _images.forEach((element) {
          if (element is File || element is String) {
            hasImages = true;
          }
        });

        Category category =
            Provider.of<CategoryNotifier>(context, listen: false)
                .selectedCategory;

        if (hasImages) {
          try {
            List selectedImages = [];

            _images.forEach((element) {
              if (element != null) selectedImages.add(element);
            });

            print(selectedImages);

            Archive result = await ApiProvider().performCreateOffer(
              selectedImages,
              _video,
              {
                "card_id": widget?.offer?.id,
                "name": _nameController.text,
                "lat": _mapInfo["lat"],
                "lng": _mapInfo["long"],
                "locality": _mapInfo["city"],
                "nacionality": _nationalityController.text,
                "description": category.type != "shared"
                    ? _offerController.text
                    : _observationsController.text,
                "requeriments": _requisitesController.text,
                "observation": category.type != "shared"
                    ? _observationsController.text
                    : _offerController.text,
                "category_id":
                    Provider.of<CategoryNotifier>(context, listen: false)
                        .selectedSubcategory
                        .id,
                "has_references": _references ? 1 : 0,
                "is_highlight": _highlight ? 1 : 0,
                "is_shared": category.type == "shared" ? 1 : 0,
              },
            );

            Provider.of<UserNotifier>(context, listen: false).saveCard(result);

            navigateTo(context, NavigationBar(initIndex: 3), willPop: true);

            navigateTo(context, ArchiveSelectionScreen());

            setState(() {
              _isLoading = false;
            });
          } catch (e) {
            setState(() {
              _isLoading = false;
            });

            catchErrors(e, _scaffoldKey);
          }
        } else {
          setState(() {
            _isLoading = false;
          });

          catchErrors(
              FormException(
                  AppLocalizations.of(context).translate("addImages")),
              _scaffoldKey);
        }
      } else {
        setState(() {
          _isLoading = false;
        });

        catchErrors(
            FormException(AppLocalizations.of(context).translate("addVideo")),
            _scaffoldKey);
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future _deleteCard() async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          title: AppLocalizations.of(context).translate("deleteOffer"),
        );
      },
    );

    if (result == true) {
      setState(() {
        _futureAdd = _delete();
      });
    }
  }

  Future _delete() async {
    try {
      UserNotifier userNotifier =
          Provider.of<UserNotifier>(context, listen: false);

      await ApiProvider().performDeleteCard({"card_id": widget.offer.id});

      userNotifier.deleteCard(widget.offer);

      Navigator.pop(context);
    } catch (e) {
      catchErrors(e, _scaffoldKey);
    }
  }
}

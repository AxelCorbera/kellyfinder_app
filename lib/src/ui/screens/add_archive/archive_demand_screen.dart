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

class ArchiveDemandScreen extends StatefulWidget {
  final Demand demand;

  const ArchiveDemandScreen({Key key, this.demand}) : super(key: key);

  @override
  _ArchiveDemandScreenState createState() => _ArchiveDemandScreenState();
}

class _ArchiveDemandScreenState extends State<ArchiveDemandScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _nameController;
  TextEditingController _surname1Controller;
  TextEditingController _surname2Controller;
  TextEditingController _locationController;
  TextEditingController _nationalityController;
  TextEditingController _demandController;
  TextEditingController _formationController;
  TextEditingController _experienceController;
  TextEditingController _observationsController;

  FocusNode _surname1Node;
  FocusNode _surname2Node;
  FocusNode _nationalityNode;
  FocusNode _demandNode;
  FocusNode _formationNode;
  FocusNode _experienceNode;
  FocusNode _observationsNode;

  bool _geoAvailable;
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

    Future.delayed(Duration.zero, (){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(
            title: AppLocalizations.of(context).translate("create_demand_popup_text"),
            hasCancel: false,
          );
        },
      );
    });

    Demand demand = widget.demand;

    Category category =
        Provider.of<CategoryNotifier>(context, listen: false).selectedCategory;

    _nameController = TextEditingController(text: demand?.name);

    // Si está creando de 0, ponemos el nombre del usuario
    if(demand == null){
      Future.delayed(Duration.zero, (){
        setState(() {
          _nameController = TextEditingController(text: Provider.of<UserNotifier>(context, listen: false).user.name);
        });
      });
    }

    _surname1Controller = TextEditingController();
    _surname2Controller = TextEditingController();

    List<String> splitSurnames = demand?.surnames?.split(" ");

    if(splitSurnames != null){
      _surname1Controller =
          TextEditingController(text: splitSurnames?.first);

      if(splitSurnames.length > 1){
        _surname2Controller =
            TextEditingController(text: demand?.surnames?.split(" ")?.last);
      }
    }

    _locationController = TextEditingController();
    _nationalityController = TextEditingController(text: demand?.nationality);
    _demandController = TextEditingController(
        text: category.type != "shared" ? demand?.desc : demand?.observations);
    _formationController = TextEditingController(text: demand?.formation);
    _experienceController = TextEditingController(text: demand?.experience);
    _observationsController = TextEditingController(
        text: category.type != "shared" ? demand?.observations : demand?.desc);

    _surname1Node = FocusNode();
    _surname2Node = FocusNode();
    _nationalityNode = FocusNode();
    _demandNode = FocusNode();
    _formationNode = FocusNode();
    _experienceNode = FocusNode();
    _observationsNode = FocusNode();

    _geoAvailable = demand?.isGeo ?? false;
    _highlight = demand?.isHighlight ?? false;
    _references = demand?.hasReferences ?? false;

    _video = demand?.video;

    _images = [];

    for (int i = 0; i < 4; i++) {
      int length = demand?.images?.length ?? 0;

      if (i < length) {
        _images.add(demand?.images[i].pic);
      } else {
        _images.add(null);
      }
    }

    User user = Provider.of<UserNotifier>(context, listen: false).user;

    if (demand != null) {
      _mapInfo = {
        "lat": demand.lat,
        "long": demand.long,
        "city": demand.locality,
      };

      _locationController.text = demand.locality;
    } else if (user.lat != null && user.long != null) {
      _mapInfo = {
        "lat": user.lat,
        "long": user.long,
        "city": user.locality,
      };

      _locationController.text = user.locality;
    } else {
      _mapInfo = {};
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surname1Controller.dispose();
    _surname2Controller.dispose();
    _locationController.dispose();
    _nationalityController.dispose();
    _demandController.dispose();
    _experienceController.dispose();
    _observationsController.dispose();

    _surname1Node.dispose();
    _surname2Node.dispose();
    _nationalityNode.dispose();
    _demandNode.dispose();
    _experienceNode.dispose();
    _observationsNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(centerTitle:true,
        title: Text(AppLocalizations.of(context).translate("demand")),
        actions: <Widget>[
          if (widget.demand != null)
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
                child: _buildForm(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm() {
    Category category =
        Provider.of<CategoryNotifier>(context, listen: false).selectedCategory;

    Category subcategory = Provider.of<CategoryNotifier>(context, listen: false)
        .selectedSubcategory;

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
          if (category.type != "social" || subcategory.type == "intern")
            CheckboxListTile(
              activeColor: Theme.of(context).buttonColor,
              value: _geoAvailable,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (value) {
                setState(() {
                  _geoAvailable = !_geoAvailable;
                });
              },
              title: Text(
                AppLocalizations.of(context).translate("activateGeo"),
              ),
              subtitle: _geoAvailable
                  ? Text(
                      AppLocalizations.of(context).translate("payOption"),
                    )
                  : null,
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
              SentenceWordsTextFormatter(),
              LengthLimitingTextInputFormatter(190),
              FilteringTextInputFormatter.deny(RegExp("[0-9]"),),
            ],
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate("name"),
              fillColor: Theme.of(context).disabledColor,
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: (value) => validateEmpty(value, context),
            onFieldSubmitted: (value) => _surname1Node.requestFocus(),
          ),
        ),
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: TextFormField(
            controller: _surname1Controller,
            focusNode: _surname1Node,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            maxLines: null,
            inputFormatters: [
              LengthLimitingTextInputFormatter(190),
              SentenceWordsTextFormatter()
            ],
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate("firstSurname"),
              fillColor: Theme.of(context).disabledColor,
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: (value) => validateEmpty(value, context),
            onFieldSubmitted: (value) => _surname2Node.requestFocus(),
          ),
        ),
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: TextFormField(
            controller: _surname2Controller,
            focusNode: _surname2Node,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            maxLines: null,
            inputFormatters: [
              LengthLimitingTextInputFormatter(190),
              SentenceWordsTextFormatter()
            ],
            decoration: InputDecoration(
              labelText:
                  AppLocalizations.of(context).translate("secondSurname"),
              fillColor: Theme.of(context).disabledColor,
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            //validator: (value) => validateEmpty(value, context),
            onFieldSubmitted: (value) => category.type != "shared"
                ? _nationalityNode.requestFocus()
                : _demandNode.requestFocus(),
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
              decoration: InputDecoration(
                labelText:
                    AppLocalizations.of(context).translate("nationality"),
                fillColor: Theme.of(context).disabledColor,
                filled: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              validator: (value) => validateEmpty(value, context),
              onFieldSubmitted: (value) => _demandNode.requestFocus(),
            ),
          ),
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: TextFormField(
            controller: _demandController,
            focusNode: _demandNode,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            maxLength: 700,
            inputFormatters: [
              new LengthLimitingTextInputFormatter(700),
              SentenceCaseTextFormatter()
            ],
            maxLines: null,
            decoration: InputDecoration(
              labelText: category.type != "shared"
                  ? AppLocalizations.of(context).translate("demand")
                  : AppLocalizations.of(context).translate("description"),
              fillColor: Theme.of(context).disabledColor,
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: (value) => validateEmpty(value, context),
            onFieldSubmitted: (value) => category.type != "shared"
                ? _formationNode.requestFocus()
                : _observationsNode.requestFocus(),
          ),
        ),
        if (category.type != "shared")
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: TextFormField(
              controller: _formationController,
              focusNode: _formationNode,
              //keyboardType: TextInputType.text,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              maxLength: 700,
              inputFormatters: [
                new LengthLimitingTextInputFormatter(700),
                SentenceCaseTextFormatter()
              ],
              minLines: 5,
              maxLines: null,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).translate("formation"),
                fillColor: Theme.of(context).disabledColor,
                alignLabelWithHint: true,
                filled: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              validator: (value) => validateEmpty(value, context),
              //onFieldSubmitted: (value) => _experienceNode.requestFocus(),
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
              controller: _experienceController,
              focusNode: _experienceNode,
              //keyboardType: TextInputType.text,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              minLines: 5,
              maxLines: null,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).translate("experience"),
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
                  : category.sharedText(context),
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

        // Check length en caso de android 9 por bug SDK
        if(category.type != "shared"){
          if(_demandController.text.length > 700 || _formationController.text.length > 700){
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CustomDialog(
                  title: AppLocalizations.of(context).translate("create_archive_caracter_exceeded"),
                  hasCancel: false,
                );
              },
            );

            return;
          }
        }

        if (hasImages) {
          try {
            List selectedImages = [];

            _images.forEach((element) {
              if (element != null) selectedImages.add(element);
            });

            final result = await ApiProvider().performCreateDemand(
              selectedImages,
              _video,
              {
                "card_id": widget?.demand?.id,
                "name": _nameController.text,
                "surnames":
                    _surname1Controller.text + " " + _surname2Controller.text,
                "lat": _mapInfo["lat"],
                "lng": _mapInfo["long"],
                "locality": _mapInfo["city"],
                "nacionality": _nationalityController.text,
                "description": category.type != "shared"
                    ? _demandController.text
                    : _observationsController.text,
                "work_experience": _experienceController.text,
                "academic_training": _formationController.text,
                "observation": category.type != "shared"
                    ? _observationsController.text
                    : _demandController.text,
                "category_id":
                    Provider.of<CategoryNotifier>(context, listen: false)
                        .selectedSubcategory
                        .id,
                "has_references": _references ? 1 : 0,
                "is_highlight": _highlight ? 1 : 0,
                "has_geographic_availability": _geoAvailable ? 1 : 0,
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
            catchErrors(e, _scaffoldKey);

            setState(() {
              _isLoading = false;
            });
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
      } else{
        setState(() {
          _isLoading = false;
        });

        catchErrors(
            FormException(AppLocalizations.of(context).translate("addVideo")),
            _scaffoldKey);
      }
    }else{
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
            title: AppLocalizations.of(context).translate("deleteDemand"));
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

      await ApiProvider().performDeleteCard({"card_id": widget.demand.id});

      userNotifier.deleteCard(widget.demand);

      Navigator.pop(context);
    } catch (e) {
      catchErrors(e, _scaffoldKey);
    }
  }
}

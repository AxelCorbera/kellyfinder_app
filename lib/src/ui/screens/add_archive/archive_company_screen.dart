import 'dart:developer';
import 'dart:io';

import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/globals.dart' as globals;
import 'package:app/src/config/sentence_case_text_formatter.dart';
import 'package:app/src/config/sentence_words_text_formatter.dart';
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/model/category.dart';
import 'package:app/src/model/industrial_park/industrial_park.dart';
import 'package:app/src/model/industrial_park/industrial_park_category.dart';
import 'package:app/src/model/municipality/municipality.dart';
import 'package:app/src/model/municipality/service.dart';
import 'package:app/src/provider/category_notifier.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/screens/add_archive/archive_selection_screen.dart';
import 'package:app/src/ui/screens/category/company_category_screen.dart';
import 'package:app/src/ui/screens/company/company_services_screen.dart';
import 'package:app/src/ui/widgets/button/custom_future_button.dart';
import 'package:app/src/ui/widgets/dialog/custom_dialog.dart';
import 'package:app/src/ui/widgets/form/archive_upper_layout.dart';
import 'package:app/src/ui/widgets/form/location_textfield.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/ui/widgets/navigation_bar.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/api/api_exception.dart';
import 'package:app/src/utils/form/form_exception.dart';
import 'package:app/src/utils/form/form_validate.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ArchiveCompanyScreen extends StatefulWidget {
  final bool fromList;
  final Company company;
  final IndustrialPark industrialPark;
  final Category industrialParkCategory;

  const ArchiveCompanyScreen({Key key, this.fromList = false, this.company, this.industrialPark, this.industrialParkCategory})
      : super(key: key);

  @override
  _ArchiveCompanyScreenState createState() => _ArchiveCompanyScreenState();
}

class _ArchiveCompanyScreenState extends State<ArchiveCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _nameController;
  TextEditingController _locationController;
  TextEditingController _webController;
  TextEditingController _descController;
  TextEditingController _observationsController;

  FocusNode _webNode;
  FocusNode _descNode;
  FocusNode _observationsNode;

  bool _allHours;
  bool _atHome;
  bool _hostelry;

  bool _municipality = false;

  int _safeValue;

  List _images;

  var _video;

  Map _mapInfo;

  Future _futureAdd;

  Future _futureMunicipality;
  bool municipalityFound = false;

  Future _futureHours;
  Future _futureDelivery;

  Category _hours;
  Category _delivery;

  Category _selectedHours;
  Category _selectedDelivery;

  bool _isLoading = false;

  int _selectedMunicipality;
  ServiceCategory _selectedService;

  @override
  void initState() {
    super.initState();

    if (widget.fromList) {
      globals.archiveType = Company;
    }

    Company company = widget.company;

    _nameController = TextEditingController(text: company?.name);

    // Si está creando de 0, ponemos el nombre del usuario
    if(company == null){
      Future.delayed(Duration.zero, (){
        setState(() {
          _nameController = TextEditingController(text: Provider.of<UserNotifier>(context, listen: false).user.name);
        });
      });
    }

    _locationController = TextEditingController();
    _webController = TextEditingController(text: company?.web);
    _descController = TextEditingController(text: company?.desc);
    _observationsController =
        TextEditingController(text: company?.recommendations);

    _webNode = FocusNode();
    _descNode = FocusNode();
    _observationsNode = FocusNode();

    _allHours = company?.is24h ?? false;
    _atHome = company?.isDelivery ?? false;
    _hostelry = company?.isHostelry ?? false;

    if(company?.municipalityId != null){
      _selectedMunicipality = company.municipalityId;
      municipalityFound = true;
      _municipality = true;
    }

    if(company?.serviceCategory != null){
      _selectedService = company.serviceCategory;
    }

    _safeValue = company?.safeValue ?? 0;

    _images = [];

    _selectedHours = company?.allHours;
    _selectedDelivery = company?.delivery;

    if (_selectedHours != null) {
      _futureHours = _getId("24h");
    }

    if (_selectedDelivery != null) {
      _futureDelivery = _getId("delivery");
    }

    for (int i = 0; i < 4; i++) {
      int length = company?.images?.length ?? 0;

      if (i < length) {
        _images.add(company?.images[i].pic);
      } else {
        _images.add(null);
      }
    }

    _video = company?.video;

    if (company != null) {
      _mapInfo = {
        "lat": company.lat,
        "long": company.long,
        "city": company.locality,
        "street": company.street,
      };

      getMunicipalityByUbication(company.lat, company.long, company.locality);

      _locationController.text =
          "${company.street?.isNotEmpty ?? false ? company.street + ", " : ""}" +
              company.locality;
    } else {
      _mapInfo = {};
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _webController.dispose();
    _descController.dispose();
    _observationsController.dispose();

    _webNode.dispose();
    _descNode.dispose();
    _observationsNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocalizations.of(context).translate("publishCompany")),
        actions: <Widget>[
          if (widget.company != null)
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

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ArchiveUpperLayout(
          images: _images,
          video: _video,
          text: additionalText(category),
          industrialParkCategory: widget.company != null ? widget.company.industrialParkCategory : widget.industrialParkCategory,
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
          videoDuration: 3,
        ),
        if (category.type != "24h")
          CheckboxListTile(
            activeColor: Theme.of(context).buttonColor,
            value: _allHours,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (value) {
              if (value) _futureHours = _getId("24h");

              setState(() {
                _allHours = !_allHours;
              });
            },
            title: Text(
              AppLocalizations.of(context).translate("open24h"),
            ),
          ),
        if (_allHours)
          FutureBuilder(
            future: _futureHours,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return Container(
                    padding: EdgeInsets.only(left: 28),
                    child: Row(
                      children: [
                        Text(
                          "${AppLocalizations.of(context).translate("category")}: ",
                        ),
                        InkWell(
                          onTap: () async {
                            final result = await navigateTo(
                              context,
                              CompanyCategoryScreen(
                                category: _hours,
                                amount: 1,
                              ),
                              isWaiting: true,
                            );

                            if (result != null) {
                              setState(() {
                                _selectedHours = result;
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              _selectedHours?.name ??
                                  AppLocalizations.of(context)
                                      .translate("select"),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }
              return FutureCircularIndicator();
            },
          ),
        if (category.type != "delivery")
          CheckboxListTile(
            activeColor: Theme.of(context).buttonColor,
            value: _atHome,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (value) {
              if (value) _futureDelivery = _getId("delivery");

              setState(() {
                _atHome = !_atHome;
              });
            },
            title: Text(
              AppLocalizations.of(context).translate("delivery"),
            ),
          ),
        if (_atHome)
          FutureBuilder(
            future: _futureDelivery,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return Container(
                    padding: EdgeInsets.only(left: 28),
                    child: Row(
                      children: [
                        Text(
                          "${AppLocalizations.of(context).translate("category")}: ",
                        ),
                        InkWell(
                          onTap: () async {
                            final result = await navigateTo(
                              context,
                              CompanyCategoryScreen(
                                category: _delivery,
                                amount: 1,
                              ),
                              isWaiting: true,
                            );
                            if (result != null) {
                              setState(() {
                                _selectedDelivery = result;
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              _selectedDelivery?.name ??
                                  AppLocalizations.of(context)
                                      .translate("select"),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }
              return FutureCircularIndicator();
            },
          ),
        if (category.type == "hostelry")
          CheckboxListTile(
            activeColor: Theme.of(context).buttonColor,
            value: _hostelry,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (value) {
              setState(() {
                _hostelry = !_hostelry;
              });
            },
            title: Text(
              AppLocalizations.of(context).translate("safeHostelry"),
            ),
          ),
        if (_hostelry)
          Container(
            padding: const EdgeInsets.only(left: 48),
            child: Column(
              children: <Widget>[
                RadioListTile(
                  value: 1,
                  groupValue: _safeValue,
                  activeColor: Theme.of(context).buttonColor,
                  onChanged: (value) {
                    setState(() {
                      _safeValue = value;
                    });
                  },
                  title: Text(
                    AppLocalizations.of(context).translate("safeRestaurant"),
                  ),
                ),
                RadioListTile(
                  value: 2,
                  groupValue: _safeValue,
                  activeColor: Theme.of(context).buttonColor,
                  title: Text(
                    AppLocalizations.of(context).translate("safeHostelry"),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _safeValue = value;
                    });
                  },
                ),
                RadioListTile(
                  value: 3,
                  groupValue: _safeValue,
                  activeColor: Theme.of(context).buttonColor,
                  title: Text(
                    AppLocalizations.of(context).translate("safeBar"),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _safeValue = value;
                    });
                  },
                ),
              ],
            ),
          ),
        SizedBox(height: 8),
        _getCategoryText(),
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: TextFormField(
            inputFormatters: [
              SentenceCaseTextFormatter()
            ],
            controller: _nameController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            maxLines: null,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate("companyName"),
              fillColor: Theme.of(context).disabledColor,
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: (value) => validateEmpty(value, context),
            onFieldSubmitted: (value) => _webNode.requestFocus(),
          ),
        ),
        LocationTextField(
          controller: _locationController,
          mapInfo: _mapInfo,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          isCompany: true,
          callback: (address) {
            setState(() {
              _locationController.text = address;
            });

            _futureMunicipality = getMunicipalityByUbication(_mapInfo['lat'], _mapInfo['long'], _mapInfo['city']);
          },
        ),
        //if(category.type == "route")
        if(widget.industrialParkCategory == null)
        IntrinsicHeight(
          child: Stack(
            children: [
              CheckboxListTile(
                title: Text(
                  AppLocalizations.of(context)
                      .translate("publishMyMunicipality"),
                ),
                value: _municipality,
                onChanged: _setCheckBox,
                activeColor: Theme.of(context).buttonColor,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              if (!municipalityFound)
                Container(
                  color: Colors.white.withOpacity(0.5),
                )
            ],
          ),
        ),
        if (_mapInfo['city'] == null && widget.industrialParkCategory == null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              AppLocalizations.of(context).translate("create_company_archive_select_location_municipality"),
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
        if (_municipality == true && widget.industrialParkCategory == null)
          Container(
            padding: EdgeInsets.only(left: 28),
            child: Row(
              children: [
                Text(
                  "${AppLocalizations.of(context).translate("services")} ",
                ),
                if (_selectedService != null)
                  Text(
                    _selectedService.name,
                    style: Theme.of(context).textTheme.subtitle1.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor),
                  ),
                InkWell(
                  onTap: () async {
                    navigateTo(context, CompanyServicesScreen(
                      callback: (ServiceCategory selectedService) {
                        setState(() {
                          _selectedService = selectedService;
                        });
                      },
                    ));
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      AppLocalizations.of(context).translate("select"),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (!municipalityFound && widget.industrialParkCategory == null)
          FutureBuilder(
            future: _futureMunicipality,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    AppLocalizations.of(context)
                        .translate("municipalityNotAdded"),
                    style: Theme.of(context).textTheme.caption,
                  ),
                );
              }
              return Container(height: 4);
            },
          ),
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: TextFormField(
            controller: _webController,
            focusNode: _webNode,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            maxLines: null,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate("web"),
              fillColor: Theme.of(context).disabledColor,
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            //validator: (value) => validateEmpty(value, context),
            onFieldSubmitted: (value) => _descNode.requestFocus(),
          ),
        ),
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: TextFormField(
            controller: _descController,
            focusNode: _descNode,
            inputFormatters: [
              SentenceCaseTextFormatter()
            ],
            //keyboardType: TextInputType.text,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            minLines: 5,
            maxLines: null,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate("description"),
              alignLabelWithHint: true,
              fillColor: Theme.of(context).disabledColor,
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: (value) => validateEmpty(value, context),
            onFieldSubmitted: (value) => _observationsNode.requestFocus(),
          ),
        ),
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: TextFormField(
            controller: _observationsController,
            focusNode: _observationsNode,
            inputFormatters: [
              SentenceCaseTextFormatter()
            ],
            //keyboardType: TextInputType.text,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            minLines: 5,
            maxLines: null,
            decoration: InputDecoration(
              labelText: category.type != "shared"
                  ? AppLocalizations.of(context)
                      .translate("recommendationsObservations")
                  : category.sharedText(context),
              alignLabelWithHint: true,
              fillColor: Theme.of(context).disabledColor,
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: (value) => validateEmpty(value, context),
            onFieldSubmitted: (value) => _observationsNode.requestFocus(),
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

  Widget _getCategoryText() {
    if (_allHours || _atHome || _hostelry) {
      Map values = {
        AppLocalizations.of(context).translate("24h"): _allHours,
        AppLocalizations.of(context).translate("atHome"): _atHome,
        AppLocalizations.of(context).translate("hostelry"): _hostelry,
      };

      values.removeWhere((key, val) {
        return val == false;
      });

      String result = "";

      int i = 0;

      values.forEach((key, value) {
        if (i == values.length - 1 && values.length != 1) {
          result =
              result + " ${AppLocalizations.of(context).translate("and")} ";
        } else if (i != 0) {
          result = result + ", ";
        }

        result = result + key;

        i++;
      });

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          "${AppLocalizations.of(context).translate("willAppear")} $result",
          style: Theme.of(context).textTheme.caption,
        ),
      );
    } else {
      return Container();
    }
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

        if (hasImages) {
          try {
            List selectedImages = [];

            _images.forEach((element) {
              if (element != null) selectedImages.add(element);
            });

            // Si ha marcado la casilla "Publicar en mi municipio",
            // comprobamos si se ha seleccionado el municipio y el servicio
            if(_municipality){
              if (_selectedMunicipality == null) {
                setState(() {
                  _isLoading = false;
                });

                catchErrors(
                    FormException(
                        AppLocalizations.of(context).translate("create_company_archive_enter_location")),
                    _scaffoldKey);

                return;
              }

              if (_selectedService == null) {
                setState(() {
                  _isLoading = false;
                });

                catchErrors(
                    FormException(
                        AppLocalizations.of(context).translate("create_company_archive_select_service")),
                    _scaffoldKey);

                return;
              }
            }

            Map params = {
              "card_id": widget?.company?.id,
              "name": _nameController.text,
              "lat": _mapInfo["lat"],
              "lng": _mapInfo["long"],
              "locality": _mapInfo["city"],
              "street": _mapInfo["street"],
              "description": _descController.text,
              "web": _webController.text,
              "recommendations": _observationsController.text,
              "is_open_all_day": _allHours ? 1 : 0,
              "do_delivery": _atHome ? 1 : 0,
            };

            // Si ha marcado la casilla "Publicar en mi municipio",
            // añadimos los params al json
            if(_municipality){
              if (_selectedMunicipality != null) {
                params.putIfAbsent("municipality_id", () => _selectedMunicipality);
              }

              if (_selectedService != null) {
                params.putIfAbsent(
                    "card_advertising_category_id", () => _selectedService.id);
              }
            }else{
              params.putIfAbsent("municipality_id", () => null);
              params.putIfAbsent("card_advertising_category_id", () => null);
            }

            Category subcategory =
                Provider.of<CategoryNotifier>(context, listen: false)
                    .selectedSubcategory;

            if (subcategory != null) {
              params.putIfAbsent("category_id", () => subcategory.id);
            } else {
              params.putIfAbsent(
                  "category_id",
                      () => Provider.of<CategoryNotifier>(context, listen: false)
                      .selectedCategory
                      .id);
            }

            // Si es polígono ponemos la categoría del polígono y su id
            if(widget.industrialParkCategory != null){
              //params.putIfAbsent("industrial_park_category_id", () => widget.industrialParkCategory.id);
              params.putIfAbsent("industrial_park_id", () => widget.industrialPark.id);
            }

            Category category =
                Provider.of<CategoryNotifier>(context, listen: false)
                    .selectedCategory;

            params.putIfAbsent("is_secure_restaurant", () => 0);
            params.putIfAbsent("is_secure_hostelry", () => 0);
            params.putIfAbsent("is_secure_bar", () => 0);

            if (category.type == "hostelry") {
              if (_hostelry) {
                if (_safeValue == 1) {
                  params["is_secure_restaurant"] = 1;
                } else if (_safeValue == 2) {
                  params["is_secure_hostelry"] = 1;
                } else if (_safeValue == 3) {
                  params["is_secure_bar"] = 1;
                }
              }
            }

            if (_allHours) {
              if (_selectedHours != null){
                params.putIfAbsent("24h_category_id", () => _selectedHours.id);
              }else{
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomDialog(
                      title: AppLocalizations.of(context).translate("create_company_24h_cat_missing"),
                      hasCancel: false,
                    );
                  },
                );
                setState(() {
                  _isLoading = false;
                });

                return;
              }
            }

            if (_atHome) {
              if (_selectedDelivery != null){
                params.putIfAbsent(
                    "delivery_category_id", () => _selectedDelivery.id);
              }else{
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomDialog(
                      title: AppLocalizations.of(context).translate("create_company_delivery_cat_missing"),
                      hasCancel: false,
                    );
                  },
                );

                setState(() {
                  _isLoading = false;
                });

                return;
              }
            }

            print("REQUEST PARAMS");
            print(params);

            final result = await ApiProvider()
                .performCreateCompany(selectedImages, _video, params);

            Provider.of<UserNotifier>(context, listen: false).saveCard(result);

            if (widget.fromList) {
              Navigator.pop(context, result);
              Navigator.pop(context, result);
            } else
              navigateTo(context, NavigationBar(initIndex: 3), willPop: true);

            navigateTo(context, ArchiveSelectionScreen());

            setState(() {
              _isLoading = false;
            });
          } catch (e) {
            print("ERROR REQUEST");
            print(e);

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
          title: AppLocalizations.of(context).translate("deleteCompany"),
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

      await ApiProvider().performDeleteCard({"card_id": widget.company.id});

      userNotifier.deleteCard(widget.company);

      Navigator.pop(context);
    } catch (e) {
      catchErrors(e, _scaffoldKey);
    }
  }

  Future _getId(String type) async {
    try {
      final result = await ApiProvider().performGetByType({"type": type});

      if (type == "24h")
        _hours = Category.fromJson(result);
      else
        _delivery = Category.fromJson(result);

      return true;
    } catch (e) {
      catchErrors(e, _scaffoldKey);
    }
  }

  String additionalText(Category category) {
    if (category.type == "social" ||
        category.type == "clean" ||
        category.type == "shared" ||
        category.type == "delivery") {
      return "${AppLocalizations.of(context).translate("services")} ";
    }
    return "";
  }

  Future getMunicipalityByUbication(double lat, double lng, String city) async {
    try {
      Map params = {
        "lat": lat,
        "lng": lng,
        "name": city
        /*"lat": _mapInfo['lat'],
        "lng": _mapInfo['long'],
        "name": _mapInfo['city']*/
      };

      Municipality _results = await ApiProvider().getMunicipalitiesByUbication(params);
      setState(() {
        log('success!');
        _selectedMunicipality = _results.id;
        municipalityFound = true;
      });

      return true;
    } on ApiException catch (e) {
      if (e.code == 404) {
        setState(() {
          municipalityFound = false;
          _selectedMunicipality = null;
          _setCheckBox(false);
        });
      }
    }
  }

  _setCheckBox(bool value) {
    setState(() {
      _municipality = value;
    });
  }
}

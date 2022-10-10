import 'dart:async';

import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/ui/widgets/button/custom_button.dart';
import 'package:app/src/ui/widgets/dialog/custom_dialog.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/api/api_google_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:app/src/config/string_casing_extension.dart';

const double _zoom = 10;

class MapScreen extends StatefulWidget {
  final TextEditingController controller;
  final Map mapInfo;
  final bool isCompany;
  final Function callback;

  const MapScreen({Key key, this.controller, this.mapInfo, this.isCompany, this.callback})
      : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  TextEditingController _locationController;

  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _initPos = CameraPosition(
    target: LatLng(31.102702, -18.295915),
    zoom: 1,
  );

  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};

  String _placeId;

  String _city;
  String _street;

  double _lat;
  double _long;

  @override
  void initState() {
    super.initState();

    _locationController = TextEditingController();

    Future.delayed(Duration(milliseconds: 500), (){
      if (widget.mapInfo.isEmpty){
        _getCurrentLocation();
      }else{
        _dataLocation();
      }
    });

  }

  @override
  void dispose() {
    _locationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle:true,
        /*leading: IconButton(
          icon: Text("OK", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),),
          onPressed: (){
            Navigator.pop(context);
          },
        ),*/
        title: TypeAheadFormField(
          textFieldConfiguration: TextFieldConfiguration(
            //controller: widget.controller,
            controller: _locationController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).translate("addDirection"),
              border: InputBorder.none,
            ),
          ),
          suggestionsCallback: (pattern) {
            if (widget.isCompany)
              return MapDirectionsApi().getStreets(
                pattern,
                AppLocalizations.of(context).locale.toString(),
              );
            else
              return MapDirectionsApi().getCities(
                pattern,
                AppLocalizations.of(context).locale.toString(),
              );
          },
          itemBuilder: (context, suggestion) {
            return ListTile(title: Text(suggestion["description"]));
          },
          transitionBuilder: (context, suggestionsBox, controller) {
            return suggestionsBox;
          },
          errorBuilder: (context, e) {
            String message = catchErrors(e, null);

            return ListTile(title: Text(message.toSentenceCase()));
          },
          noItemsFoundBuilder: (context) {
            return ListTile(
                title: Text(AppLocalizations.of(context).translate("noInfo")));
          },
          onSuggestionSelected: (suggestion) async {
            if (widget.isCompany)
              _street = suggestion["structured_formatting"]["main_text"];

            _placeId = suggestion["place_id"];

            Map data = await MapDirectionsApi().getInfoPlaceById(_placeId);

            widget.mapInfo.clear();

            _lat = double.parse(data["lat"]);
            _long = double.parse(data["long"]);
            _city = data["city"];

            if (!widget.isCompany)
              _locationController.text = "$_city";
            else
              _locationController.text =
                  "${_street.isNotEmpty ? _street + ", " : ""}${_city != null ? _city : ""}";

            /*widget.mapInfo.addAll({
              "lat": _lat,
              "long": _long,
              "city": _city,
            });

            if (widget.isCompany)
              widget.mapInfo.putIfAbsent("street", () => _street);*/

            await moveCamera(_lat, _long);
            await addMarker(_lat, _long);
          },
          keepSuggestionsOnLoading: false,
          getImmediateSuggestions: false,
          hideOnEmpty: true,
          hideSuggestionsOnKeyboardHide: true,
          hideOnLoading: true,
        ),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initPos,
            onLongPress: _handleMapAction,
            onTap: _handleMapAction,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            markers: Set<Marker>.of(_markers.values),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Center(
              child: Opacity(
                opacity: _lat != null ? 1 : 0.7,
                child: CustomButton(
                  text: AppLocalizations.of(context).translate("accept"),
                  function: (){
                    if(_lat != null){

                      widget.mapInfo.clear();

                      widget.mapInfo.addAll({
                        "lat": _lat,
                        "long": _long,
                        "city": _city,
                      });

                      if (widget.isCompany)
                        widget.mapInfo.putIfAbsent("street", () => _street);

                      widget.callback(_locationController.text);

                      Navigator.pop(context);
                    }else{
                      // alert
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomDialog(
                            title: AppLocalizations.of(context).translate("map_location_not_selected"),
                            hasCancel: false,
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          )
        ],
      )
    );
  }

  Future _getCurrentLocation() async {
    Position position =
        await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    await moveCamera(position.latitude, position.longitude);
  }

  Future _dataLocation() async {
    setState(() {
      if(widget.mapInfo["lat"] != null){
        _lat = widget.mapInfo["lat"];
        _long = widget.mapInfo["long"];
      }

      if(widget.mapInfo["city"] != null){
        _city = widget.mapInfo["city"];
      }else{
        _handleMapAction(LatLng(_lat, _long));
      }

      if(widget.mapInfo["street"] != null)
        _street = widget.mapInfo["street"];
    });

    await moveCamera(_lat, _long);

    if(widget.mapInfo["city"] != null){
      print("add marker");
      await addMarker(_lat, _long);
    }
  }

  Future moveCamera(double lat, double long) async {
    final CameraPosition _position = CameraPosition(
      target: LatLng(lat, long),
      zoom: _zoom,
    );

    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(CameraUpdate.newCameraPosition(_position));
  }

  Future addMarker(double lat, double long) async {
    final String markerIdVal = 'marker_id_0';

    final MarkerId markerId = MarkerId(markerIdVal);

    String text = "";

    if (!widget.isCompany){
      text = "$_city";
    } else{
      if(_street != null)
        text = "${_street.isNotEmpty ? _street + ", " : ""}$_city";
    }

    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(lat, long),
      infoWindow: InfoWindow(title: text),
    );

    setState(() {
      _locationController.text = text;
      _markers[markerId] = marker;
    });
  }

  Future _handleMapAction(LatLng pos) async {
    try {
      Map data = await MapDirectionsApi()
          .getInfoPlaceByGeo(pos.latitude, pos.longitude);

      _city = data["city"] ?? "";
      _street = data["street"] ?? "";

      if (!widget.isCompany)
        _locationController.text = "$_city";
      else
        _locationController.text =
            "${_street.isNotEmpty ? _street + ", " : ""}$_city";

      _lat = pos.latitude;
      _long = pos.longitude;

      /*widget.mapInfo.clear();

      widget.mapInfo.addAll({
        "lat": pos.latitude,
        "long": pos.longitude,
        "city": _city,
      });

      if (widget.isCompany) widget.mapInfo.putIfAbsent("street", () => _street);*/

      await moveCamera(pos.latitude, pos.longitude);
      await addMarker(pos.latitude, pos.longitude);
    } catch (e) {}
  }
}

import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/globals.dart' as globals;
import 'package:app/src/utils/constants/searching_type.dart';
import 'package:flutter/material.dart';

const double _width = 120;
const double _radius = 40;

class SearchSliderButton extends StatefulWidget {
  final Function callback;

  const SearchSliderButton({Key key, this.callback}) : super(key: key);

  @override
  _SearchSliderButtonState createState() => _SearchSliderButtonState();
}

class _SearchSliderButtonState extends State<SearchSliderButton> {
  double _left;
  double _right;

  @override
  void initState() {
    super.initState();
    if (globals.searchingType == SearchingType.OFFER) {
      _left = 0;
      _right = _width;
    } else {
      _left = _width;
      _right = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(_radius)),
        clipBehavior: Clip.hardEdge,
        elevation: 3,
        child: Container(
          color: Theme.of(context).primaryColorLight.withOpacity(0.8),
          child: InkWell(
            onTap: () {},
            child: Container(
              height: 36,
              padding: const EdgeInsets.all(2),
              child: Stack(
                children: <Widget>[
                  AnimatedPositioned(
                    left: _left,
                    bottom: 0,
                    top: 0,
                    right: _right,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).accentColor,
                        borderRadius: BorderRadius.all(
                          Radius.circular(_radius),
                        ),
                      ),
                    ),
                    duration: Duration(milliseconds: 200),
                  ),
                  Positioned(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            setState(() {
                              _left = 0;
                              _right = _width;
                              globals.searchingType = SearchingType.OFFER;
                            });

                            if (widget.callback != null) widget.callback();
                          },
                          child: Container(
                            width: _width,
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context).translate("jobs"),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: globals.searchingType ==
                                          SearchingType.OFFER
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).accentColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            setState(() {
                              _right = 0;
                              _left = _width;
                              globals.searchingType = SearchingType.DEMAND;
                            });

                            if (widget.callback != null) widget.callback();
                          },
                          child: Container(
                            width: _width,
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context)
                                    .translate("employees"),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: globals.searchingType ==
                                          SearchingType.DEMAND
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).accentColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

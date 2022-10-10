import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/sentence_case_text_formatter.dart';
import 'package:app/src/config/string_casing_extension.dart';
import 'package:app/src/ui/screens/map/map_screen.dart';
import 'package:app/src/utils/form/form_validate.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';

class LocationTextField extends StatelessWidget {
  final TextEditingController controller;
  final EdgeInsets padding;
  final Map mapInfo;
  final bool isCompany;
  final Function callback;
  final String text;
  final bool mustValidate;

  const LocationTextField(
      {Key key, this.controller, this.padding, this.mapInfo, this.isCompany = false, this.callback, this.text, this.mustValidate = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: padding,
      title: FocusScope(
        node: new FocusScopeNode(),
        child: TextFormField(
          inputFormatters: [
            SentenceCaseTextFormatter()
          ],
          controller: controller,
          readOnly: true,
          enableInteractiveSelection: false,
          decoration: InputDecoration(
            labelText: text ?? AppLocalizations.of(context).translate("addDirection"),
            fillColor: Theme.of(context).disabledColor,
            filled: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: Icon(Icons.my_location),
            border: InputBorder.none,
          ),
          validator: (value) => mustValidate ? validateEmpty(value, context) : null,
          onTap: () {
            navigateTo(
              context,
              MapScreen(
                controller: controller,
                mapInfo: mapInfo,
                isCompany: isCompany,
                callback: callback,
              ),
            );
          },
        ),
      ),
    );
  }
}

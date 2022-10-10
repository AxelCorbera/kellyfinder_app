import 'package:flutter/services.dart';
import 'package:app/src/config/string_casing_extension.dart';

class SentenceCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue,
      TextEditingValue newValue) {
    return new TextEditingValue(
      text: newValue.text.toSentenceCase(),
      selection: newValue.selection,
    );
  }
}
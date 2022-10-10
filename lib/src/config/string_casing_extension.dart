extension StringCasingExtension on String {
  String toCapitalized() => length > 0 ?'${this[0].toUpperCase()}${substring(1)}':'';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized()).join(' ');
  String toSentenceCase() => replaceAll(RegExp(' +'), ' ').split('. ').map((str) => str.toCapitalized()).join('. ');
}

//import 'package:app/src/config/string_casing_extension.dart';
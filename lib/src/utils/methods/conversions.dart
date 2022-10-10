import 'package:intl/intl.dart';

String priceToString(double price) {
  return "${price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2)}€";
}

String formatStringDate(String date){
  return DateFormat('dd/MM/yyyy').format(DateTime.parse(date));
}
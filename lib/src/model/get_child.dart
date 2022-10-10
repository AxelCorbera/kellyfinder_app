import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/model/municipality/municipality.dart';
import 'package:app/src/model/support/conversion.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class GetChild {
  int num_cards;

  GetChild({
    this.num_cards
  });

  factory GetChild.fromJson(Map<String, dynamic> json) => GetChild(
      num_cards: json['num_cards']);

  Map<String, dynamic> toJson() {
    return {"num_cards":num_cards};
  }

}

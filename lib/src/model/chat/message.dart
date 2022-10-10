import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/support/conversion.dart';
import 'package:app/src/model/user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  final int id;
  @JsonKey(name: "message")
  final String text;
  @JsonKey(name: "created_at")
  final String date;
  final User user;
  @JsonKey(name: "has_been_read", fromJson: Conversion.intToBool)
  final bool hasBeenRead;

  Message({
    int id,
    String text,
    User user,
    @required String date,
    bool hasBeenRead,
  })  : this.id = id,
        this.text = text,
        this.date = date,
        this.hasBeenRead = hasBeenRead,
        this.user = user;

  String getDate(BuildContext context) {
    Duration difference = DateTime.now().timeZoneOffset;

    DateTime dateTime = DateTime.parse(this.date).add(difference);

    Duration time = DateTime.now().difference(dateTime);

    //print(time.inDays);

    if (time.inDays < 365) {
      if (time.inDays < 1) {
        return DateFormat.Hm(AppLocalizations.of(context).locale.toString())
            .format(dateTime);
      }

      return DateFormat.Md(AppLocalizations.of(context).locale.toString())
          .add_Hm()
          .format(dateTime);
    } else {
      return DateFormat.yMd(AppLocalizations.of(context).locale.toString())
          .format(dateTime);
    }
  }

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

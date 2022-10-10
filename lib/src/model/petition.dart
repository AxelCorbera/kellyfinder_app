import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/model/support/conversion.dart';
import 'package:app/src/model/user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'petition.g.dart';

@JsonSerializable()
class Petition {
  int id;
  @JsonKey(name: "requested_card", fromJson: Conversion.typeToArchive)
  Archive requestedCard;
  @JsonKey(name: "requester_card", fromJson: Conversion.typeToArchive)
  Archive requesterCard;
  @JsonKey(name: "is_active", fromJson: Conversion.intToBool)
  bool isActive;
  @JsonKey(name: "is_deleted", fromJson: Conversion.intToBool)
  bool isDeleted;
  @JsonKey(name: "requester_user")
  User requesterUser;
  @JsonKey(name: "requested_user")
  User requestedUser;
  @JsonKey(name: "created_at")
  String date;
  String comment;

  Petition(
      this.id,
      this.requestedCard,
      this.requesterCard,
      this.isActive,
      this.isDeleted,
      this.requestedUser,
      this.requesterUser,
      this.date,
      this.comment);

  factory Petition.fromJson(Map<String, dynamic> json) =>
      _$PetitionFromJson(json);

  Map<String, dynamic> toJson() => _$PetitionToJson(this);

  String getDate(BuildContext context) {
    final f =
        new DateFormat.yMd(AppLocalizations.of(context).locale.toString());

    String formattedDate = f.format(DateTime.parse(this.date));

    return formattedDate;
  }
}

import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/category.dart';
import 'package:app/src/model/industrial_park/industrial_park_category.dart';
import 'package:app/src/model/municipality/service.dart';
import 'package:app/src/model/support/conversion.dart';
import 'package:app/src/model/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'archive.g.dart';

@JsonSerializable()
class Archive {
  @JsonKey(name: "card_id")
  int id;
  String name;
  String video;
  @JsonKey(name: "pics")
  List<ArchiveImage> images;
  @JsonKey(name: "description")
  String desc;
  @JsonKey(name: "created_at")
  String date;
  double distance;
  @JsonKey(name: "nacionality")
  String nationality;
  String locality;
  @JsonKey(fromJson: Conversion.stringToDouble)
  double lat;
  @JsonKey(name: "lng", fromJson: Conversion.stringToDouble)
  double long;
  User user;
  @JsonKey(name: "is_favorite_card", fromJson: Conversion.intToBool)
  bool isFavorite;
  @JsonKey(name: "is_request_accepted", fromJson: Conversion.intToBool)
  bool isAccepted;
  @JsonKey(name: "is_request_sended", fromJson: Conversion.intToBool)
  bool isSent;
  @JsonKey(name: "has_match_card")
  List<int> matchCard;
  @JsonKey(toJson: Conversion.objectToJson)
  Category category;

  Archive(
    this.id,
    this.name,
    this.video,
    this.images,
    this.desc,
    this.date,
    this.distance,
    this.nationality,
    this.locality,
    this.lat,
    this.long,
    this.user,
    this.isFavorite,
    this.isAccepted,
    this.isSent,
    this.category,
  );

  String get distanceAsString {
    if (distance != null) {
      if (distance > 1)
        return "${distance.toStringAsFixed(distance.truncateToDouble() == distance ? 0 : 2)} km";
      else
        return "${distance.toStringAsFixed(3).split(".")[1]} m";
    } else
      return "";
  }

  factory Archive.fromJson(Map<String, dynamic> json) =>
      _$ArchiveFromJson(json);

  Map<String, dynamic> toJson() => _$ArchiveToJson(this);

  String getDate(BuildContext context) {
    final f =
        new DateFormat.yMd(AppLocalizations.of(context).locale.toString());

    String formattedDate = f.format(DateTime.parse(this.date));

    return formattedDate;
  }
}

@JsonSerializable()
class Offer extends Archive {
  @JsonKey(name: "requeriments")
  String requisites;
  @JsonKey(name: "has_references", fromJson: Conversion.intToBool)
  bool hasReferences;
  @JsonKey(name: "is_highlight", fromJson: Conversion.intToBool)
  bool isHighlight;
  @JsonKey(name: "observation")
  String observations;

  Offer(
    int id,
    String name,
    String video,
    List<ArchiveImage> images,
    String desc,
    String date,
    double distance,
    String nationality,
    String requisites,
    bool hasReferences,
    bool isHighlight,
    String observations,
    String locality,
    double lat,
    double long,
    User user,
    bool isFavorite,
    bool isAccepted,
    bool isSent,
    Category category,
  )   : this.requisites = requisites,
        this.hasReferences = hasReferences,
        this.observations = observations,
        this.isHighlight = isHighlight,
        super(
            id,
            name,
            video,
            images,
            desc,
            date,
            distance,
            nationality,
            locality,
            lat,
            long,
            user,
            isFavorite,
            isAccepted,
            isSent,
            category);

  factory Offer.fromJson(Map<String, dynamic> json) => _$OfferFromJson(json);

  Map<String, dynamic> toJson() => _$OfferToJson(this);
}

@JsonSerializable()
class Demand extends Archive {
  @JsonKey(name: "academic_training")
  String formation;
  @JsonKey(name: "work_experience")
  String experience;
  @JsonKey(name: "has_references", fromJson: Conversion.intToBool)
  bool hasReferences;
  @JsonKey(name: "is_highlight", fromJson: Conversion.intToBool)
  bool isHighlight;
  @JsonKey(name: "has_geographic_availability", fromJson: Conversion.intToBool)
  bool isGeo;
  @JsonKey(name: "observation")
  String observations;
  String surnames;

  Demand(
    int id,
    String name,
    String video,
    List<ArchiveImage> images,
    String desc,
    String date,
    double distance,
    String nationality,
    String formation,
    String experience,
    bool hasReferences,
    bool isGeo,
    bool isHighlight,
    String observations,
    String locality,
    double lat,
    double long,
    User user,
    bool isFavorite,
    bool isAccepted,
    bool isSent,
    Category category,
    String surnames,
  )   : this.experience = experience,
        this.formation = formation,
        this.hasReferences = hasReferences,
        this.observations = observations,
        this.surnames = surnames,
        this.isHighlight = isHighlight,
        this.isGeo = isGeo,
        super(
            id,
            name,
            video,
            images,
            desc,
            date,
            distance,
            nationality,
            locality,
            lat,
            long,
            user,
            isFavorite,
            isAccepted,
            isSent,
            category);

  factory Demand.fromJson(Map<String, dynamic> json) => _$DemandFromJson(json);

  Map<String, dynamic> toJson() => _$DemandToJson(this);
}

@JsonSerializable()
class Company extends Archive {
  String web;
  String recommendations;
  @JsonKey(name: "is_open_all_day", fromJson: Conversion.intToBool)
  bool is24h;
  @JsonKey(name: "do_delivery", fromJson: Conversion.intToBool)
  bool isDelivery;
  @JsonKey(name: "is_secure_bar", fromJson: Conversion.intToBool)
  bool isBarSecure;
  @JsonKey(name: "is_secure_restaurant", fromJson: Conversion.intToBool)
  bool isRestaurantSecure;
  @JsonKey(name: "is_secure_hostelry", fromJson: Conversion.intToBool)
  bool isHostelrySecure;
  String street;
  @JsonKey(name: "all_hours")
  Category allHours;
  @JsonKey(name: "delivery")
  Category delivery;
  @JsonKey(name: "municipality_id")
  int municipalityId;
  @JsonKey(name: "card_advertising_category")
  ServiceCategory serviceCategory;
  @JsonKey(name: "industrial_park_category")
  Category industrialParkCategory;

  Company(
    int id,
    String name,
    String video,
    List<ArchiveImage> images,
    String desc,
    String date,
    double distance,
    String nationality,
    String web,
    String recommendations,
    String locality,
    double lat,
    double long,
    User user,
    bool isFavorite,
    bool isAccepted,
    bool isSent,
    Category category,
    bool is24h,
    bool isDelivery,
    bool isBarSecure,
    bool isRestaurantSecure,
    bool isHostelrySecure,
    String street,
    Category allHours,
    Category delivery,
    int municipalityId,
    ServiceCategory serviceCategory,
    Category industrialParkCategory,
  )   : this.web = web,
        this.recommendations = recommendations,
        this.is24h = is24h,
        this.isDelivery = isDelivery,
        this.isBarSecure = isBarSecure,
        this.isRestaurantSecure = isRestaurantSecure,
        this.isHostelrySecure = isHostelrySecure,
        this.street = street,
        this.allHours = allHours,
        this.delivery = delivery,
        this.municipalityId = municipalityId,
        this.serviceCategory = serviceCategory,
        this.industrialParkCategory = industrialParkCategory,
        super(
            id,
            name,
            video,
            images,
            desc,
            date,
            distance,
            nationality,
            locality,
            lat,
            long,
            user,
            isFavorite,
            isAccepted,
            isSent,
            category);

  factory Company.fromJson(Map<String, dynamic> json) =>
      _$CompanyFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyToJson(this);

  bool get isHostelry {
    if (isRestaurantSecure) {
      return true;
    } else if (isBarSecure) {
      return true;
    } else if (isHostelrySecure) {
      return true;
    } else {
      return false;
    }
  }

  int get safeValue {
    if (isRestaurantSecure) {
      return 1;
    } else if (isBarSecure) {
      return 3;
    } else if (isHostelrySecure) {
      return 2;
    } else {
      return 0;
    }
  }

  String safeText(BuildContext context) {
    if (isRestaurantSecure) {
      return "Restaurante seguro";
    } else if (isBarSecure) {
      return "Bar seguro";
    } else if (isHostelrySecure) {
      return "Hostelería segura";
    } else {
      return "";
    }
  }

  String get direction {
    return "${street?.isNotEmpty ?? false ? street + ", " : ""}" + locality;
  }
}

@JsonSerializable()
class ArchiveImage {
  String pic;

  ArchiveImage(this.pic);

  factory ArchiveImage.fromJson(Map<String, dynamic> json) =>
      _$ArchiveImageFromJson(json);

  Map<String, dynamic> toJson() => _$ArchiveImageToJson(this);
}

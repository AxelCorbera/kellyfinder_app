import 'package:app/src/model/municipality/autonomous_community.dart';
import 'package:app/src/model/municipality/province.dart';

class Municipality {
  int id;
  String name;
  String customName;
  String major;
  int population;
  String phone;
  String email;
  String directionTownHall;
  double lat;
  double lng;
  double distance;
  String video;
  Province province;
  AutonomousCommunity community;
  int elevation;
  String politicalParty;
  bool isRegistered;
  bool isAttached;
  String description;

  Municipality(
      {this.id,
      this.name,
      this.customName,
      this.major,
      this.population,
      this.phone,
      this.email,
      this.directionTownHall,
      this.lat,
      this.lng,
      this.distance,
      this.video,
      this.province,
      this.community,
      this.elevation,
      this.politicalParty,
      this.isRegistered,
      this.isAttached,
      this.description});

  factory Municipality.fromJson(Map<String, dynamic> json) {
    AutonomousCommunity ac;
    Province province;

    if (json['community'] != null) {
      ac = AutonomousCommunity.fromJson(json['community']);
    }

    if (json['province'] != null) {
      province = Province.fromJson(json['province']);
    }

    return Municipality(
        id: json['id'] as int,
        name: json['name'] as String,
        customName: json['custom_name'] as String,
        major: json['major'] as String,
        population: json['population'] as int,
        phone: json['phone'] as String,
        email: json['email'] as String,
        directionTownHall: json['direction_town_hall'] as String,
        lat: (json['lat'] as num)?.toDouble(),
        lng: (json['lng'] as num)?.toDouble(),
        distance: json["distance"] != null
            ? double.tryParse(json["distance"].toString())
            : null,
        video: json['video'] as String,
        province: province,
        community: ac,
        elevation: json['elevation'] as int,
        politicalParty: json['political_party'] as String,
        isRegistered: json['is_registered'] as bool,
        isAttached: json['is_attached'] as bool,
        description: json['description'] as String
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "major": major,
        "population": population,
        "phone": phone,
        "email": email,
        "lat": lat,
        "lng": lng,
        "distance": distance,
        "direction_town_hall": directionTownHall,
        "video": video,
        "elevation": elevation,
        "custom_name": customName,
        "political_party": politicalParty,
        "is_registered": isRegistered,
        "community": community.toJson(),
        "province": province.toJson(),
        "is_attached": isAttached,
        "description": description
      };
}

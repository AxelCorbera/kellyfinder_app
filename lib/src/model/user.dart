import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/model/municipality/municipality.dart';
import 'package:app/src/model/support/conversion.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class AppUser {
  @JsonKey(name: "access_token")
  String accessToken;
  User user;
  @JsonKey(toJson: Conversion.listToJson)
  List<Offer> offers;
  @JsonKey(toJson: Conversion.listToJson)
  List<Demand> demands;
  @JsonKey(toJson: Conversion.listToJson)
  List<Company> companies;
  Municipality municipality;

  AppUser(
    this.accessToken,
    this.user,
    this.offers,
    this.demands,
    this.companies,
    this.municipality,
  );

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);

  Map<String, dynamic> toJson() {
    return _$AppUserToJson(this);
  }

  //bool get hasCards => offers != null && demands != null && companies != null;
  bool get hasCards => offers.length > 0 || demands.length > 0 || companies.length > 0;
}

@JsonSerializable()
class User {
  int id;
  String name;
  @JsonKey(name: "avatar")
  String image;
  String email;
  @JsonKey(fromJson: Conversion.stringToDouble)
  double lat;
  @JsonKey(name: "lng", fromJson: Conversion.stringToDouble)
  double long;
  String locality;
  @JsonKey(name: "blocked_users")
  List<User> blockedUsers;

  User(this.id, this.name, this.image, this.email, this.lat, this.long,
      this.locality, this.blockedUsers);

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

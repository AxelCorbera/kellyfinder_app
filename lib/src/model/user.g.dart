// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppUser _$AppUserFromJson(Map<String, dynamic> json) {
  return AppUser(
    json['access_token'] as String,
    json['user'] == null
        ? null
        : User.fromJson(json['user'] as Map<String, dynamic>),
    (json['offers'] as List)
        ?.map(
            (e) => e == null ? null : Offer.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    (json['demands'] as List)
        ?.map((e) =>
            e == null ? null : Demand.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    (json['companies'] as List)
        ?.map((e) =>
            e == null ? null : Company.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['municipality'] == null
        ? null
        : Municipality.fromJson(json['municipality'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$AppUserToJson(AppUser instance) => <String, dynamic>{
      'access_token': instance.accessToken,
      'user': instance.user,
      'offers': Conversion.listToJson(instance.offers),
      'demands': Conversion.listToJson(instance.demands),
      'companies': Conversion.listToJson(instance.companies),
      'municipality': instance.municipality,
    };

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    json['id'] as int,
    json['name'] as String,
    json['avatar'] as String,
    json['email'] as String,
    Conversion.stringToDouble(json['lat']),
    Conversion.stringToDouble(json['lng']),
    json['locality'] as String,
    (json['blocked_users'] as List)
        ?.map(
            (e) => e == null ? null : User.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'avatar': instance.image,
      'email': instance.email,
      'lat': instance.lat,
      'lng': instance.long,
      'locality': instance.locality,
      'blocked_users': instance.blockedUsers,
    };

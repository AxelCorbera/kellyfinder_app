// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'archive.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Archive _$ArchiveFromJson(Map<String, dynamic> json) {
  return Archive(
    json['card_id'] as int,
    json['name'] as String,
    json['video'] as String,
    (json['pics'] as List)
        ?.map((e) =>
            e == null ? null : ArchiveImage.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['description'] as String,
    json['created_at'] as String,
    (json['distance'] as num)?.toDouble(),
    json['nacionality'] as String,
    json['locality'] as String,
    Conversion.stringToDouble(json['lat']),
    Conversion.stringToDouble(json['lng']),
    json['user'] == null
        ? null
        : User.fromJson(json['user'] as Map<String, dynamic>),
    Conversion.intToBool(json['is_favorite_card']),
    Conversion.intToBool(json['is_request_accepted']),
    Conversion.intToBool(json['is_request_sended']),
    json['category'] == null
        ? null
        : Category.fromJson(json['category'] as Map<String, dynamic>),
  )..matchCard =
      (json['has_match_card'] as List)?.map((e) => e as int)?.toList();
}

Map<String, dynamic> _$ArchiveToJson(Archive instance) => <String, dynamic>{
      'card_id': instance.id,
      'name': instance.name,
      'video': instance.video,
      'pics': instance.images,
      'description': instance.desc,
      'created_at': instance.date,
      'distance': instance.distance,
      'nacionality': instance.nationality,
      'locality': instance.locality,
      'lat': instance.lat,
      'lng': instance.long,
      'user': instance.user,
      'is_favorite_card': instance.isFavorite,
      'is_request_accepted': instance.isAccepted,
      'is_request_sended': instance.isSent,
      'has_match_card': instance.matchCard,
      'category': Conversion.objectToJson(instance.category),
    };

Offer _$OfferFromJson(Map<String, dynamic> json) {
  return Offer(
    json['card_id'] as int,
    json['name'] as String,
    json['video'] as String,
    (json['pics'] as List)
        ?.map((e) =>
            e == null ? null : ArchiveImage.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['description'] as String,
    json['created_at'] as String,
    (json['distance'] as num)?.toDouble(),
    json['nacionality'] as String,
    json['requeriments'] as String,
    Conversion.intToBool(json['has_references']),
    Conversion.intToBool(json['is_highlight']),
    json['observation'] as String,
    json['locality'] as String,
    Conversion.stringToDouble(json['lat']),
    Conversion.stringToDouble(json['lng']),
    json['user'] == null
        ? null
        : User.fromJson(json['user'] as Map<String, dynamic>),
    Conversion.intToBool(json['is_favorite_card']),
    Conversion.intToBool(json['is_request_accepted']),
    Conversion.intToBool(json['is_request_sended']),
    json['category'] == null
        ? null
        : Category.fromJson(json['category'] as Map<String, dynamic>),
  )..matchCard =
      (json['has_match_card'] as List)?.map((e) => e as int)?.toList();
}

Map<String, dynamic> _$OfferToJson(Offer instance) => <String, dynamic>{
      'card_id': instance.id,
      'name': instance.name,
      'video': instance.video,
      'pics': instance.images,
      'description': instance.desc,
      'created_at': instance.date,
      'distance': instance.distance,
      'nacionality': instance.nationality,
      'locality': instance.locality,
      'lat': instance.lat,
      'lng': instance.long,
      'user': instance.user,
      'is_favorite_card': instance.isFavorite,
      'is_request_accepted': instance.isAccepted,
      'is_request_sended': instance.isSent,
      'has_match_card': instance.matchCard,
      'category': Conversion.objectToJson(instance.category),
      'requeriments': instance.requisites,
      'has_references': instance.hasReferences,
      'is_highlight': instance.isHighlight,
      'observation': instance.observations,
    };

Demand _$DemandFromJson(Map<String, dynamic> json) {
  return Demand(
    json['card_id'] as int,
    json['name'] as String,
    json['video'] as String,
    (json['pics'] as List)
        ?.map((e) =>
            e == null ? null : ArchiveImage.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['description'] as String,
    json['created_at'] as String,
    (json['distance'] as num)?.toDouble(),
    json['nacionality'] as String,
    json['academic_training'] as String,
    json['work_experience'] as String,
    Conversion.intToBool(json['has_references']),
    Conversion.intToBool(json['has_geographic_availability']),
    Conversion.intToBool(json['is_highlight']),
    json['observation'] as String,
    json['locality'] as String,
    Conversion.stringToDouble(json['lat']),
    Conversion.stringToDouble(json['lng']),
    json['user'] == null
        ? null
        : User.fromJson(json['user'] as Map<String, dynamic>),
    Conversion.intToBool(json['is_favorite_card']),
    Conversion.intToBool(json['is_request_accepted']),
    Conversion.intToBool(json['is_request_sended']),
    json['category'] == null
        ? null
        : Category.fromJson(json['category'] as Map<String, dynamic>),
    json['surnames'] as String,
  )..matchCard =
      (json['has_match_card'] as List)?.map((e) => e as int)?.toList();
}

Map<String, dynamic> _$DemandToJson(Demand instance) => <String, dynamic>{
      'card_id': instance.id,
      'name': instance.name,
      'video': instance.video,
      'pics': instance.images,
      'description': instance.desc,
      'created_at': instance.date,
      'distance': instance.distance,
      'nacionality': instance.nationality,
      'locality': instance.locality,
      'lat': instance.lat,
      'lng': instance.long,
      'user': instance.user,
      'is_favorite_card': instance.isFavorite,
      'is_request_accepted': instance.isAccepted,
      'is_request_sended': instance.isSent,
      'has_match_card': instance.matchCard,
      'category': Conversion.objectToJson(instance.category),
      'academic_training': instance.formation,
      'work_experience': instance.experience,
      'has_references': instance.hasReferences,
      'is_highlight': instance.isHighlight,
      'has_geographic_availability': instance.isGeo,
      'observation': instance.observations,
      'surnames': instance.surnames,
    };

Company _$CompanyFromJson(Map<String, dynamic> json) {
  return Company(
    json['card_id'] as int,
    json['name'] as String,
    json['video'] as String,
    (json['pics'] as List)
        ?.map((e) =>
            e == null ? null : ArchiveImage.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['description'] as String,
    json['created_at'] as String,
    (json['distance'] as num)?.toDouble(),
    json['nacionality'] as String,
    json['web'] as String,
    json['recommendations'] as String,
    json['locality'] as String,
    Conversion.stringToDouble(json['lat']),
    Conversion.stringToDouble(json['lng']),
    json['user'] == null
        ? null
        : User.fromJson(json['user'] as Map<String, dynamic>),
    Conversion.intToBool(json['is_favorite_card']),
    Conversion.intToBool(json['is_request_accepted']),
    Conversion.intToBool(json['is_request_sended']),
    json['category'] == null
        ? null
        : Category.fromJson(json['category'] as Map<String, dynamic>),
    Conversion.intToBool(json['is_open_all_day']),
    Conversion.intToBool(json['do_delivery']),
    Conversion.intToBool(json['is_secure_bar']),
    Conversion.intToBool(json['is_secure_restaurant']),
    Conversion.intToBool(json['is_secure_hostelry']),
    json['street'] as String,
    json['all_hours'] == null
        ? null
        : Category.fromJson(json['all_hours'] as Map<String, dynamic>),
    json['delivery'] == null
        ? null
        : Category.fromJson(json['delivery'] as Map<String, dynamic>),
    json['municipality_id'] as int,
    json['card_advertising_category'] == null
        ? null
        : ServiceCategory.fromJson(
            json['card_advertising_category'] as Map<String, dynamic>),
    json['industrial_park_category'] == null
        ? null
        : Category.fromJson(
            json['industrial_park_category'] as Map<String, dynamic>),
  )..matchCard =
      (json['has_match_card'] as List)?.map((e) => e as int)?.toList();
}

Map<String, dynamic> _$CompanyToJson(Company instance) => <String, dynamic>{
      'card_id': instance.id,
      'name': instance.name,
      'video': instance.video,
      'pics': instance.images,
      'description': instance.desc,
      'created_at': instance.date,
      'distance': instance.distance,
      'nacionality': instance.nationality,
      'locality': instance.locality,
      'lat': instance.lat,
      'lng': instance.long,
      'user': instance.user,
      'is_favorite_card': instance.isFavorite,
      'is_request_accepted': instance.isAccepted,
      'is_request_sended': instance.isSent,
      'has_match_card': instance.matchCard,
      'category': Conversion.objectToJson(instance.category),
      'web': instance.web,
      'recommendations': instance.recommendations,
      'is_open_all_day': instance.is24h,
      'do_delivery': instance.isDelivery,
      'is_secure_bar': instance.isBarSecure,
      'is_secure_restaurant': instance.isRestaurantSecure,
      'is_secure_hostelry': instance.isHostelrySecure,
      'street': instance.street,
      'all_hours': instance.allHours,
      'delivery': instance.delivery,
      'municipality_id': instance.municipalityId,
      'card_advertising_category': instance.serviceCategory,
      'industrial_park_category': instance.industrialParkCategory,
    };

ArchiveImage _$ArchiveImageFromJson(Map<String, dynamic> json) {
  return ArchiveImage(
    json['pic'] as String,
  );
}

Map<String, dynamic> _$ArchiveImageToJson(ArchiveImage instance) =>
    <String, dynamic>{
      'pic': instance.pic,
    };

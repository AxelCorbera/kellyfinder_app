// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'petition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Petition _$PetitionFromJson(Map<String, dynamic> json) {
  return Petition(
    json['id'] as int,
    Conversion.typeToArchive(json['requested_card']),
    Conversion.typeToArchive(json['requester_card']),
    Conversion.intToBool(json['is_active']),
    Conversion.intToBool(json['is_deleted']),
    json['requested_user'] == null
        ? null
        : User.fromJson(json['requested_user'] as Map<String, dynamic>),
    json['requester_user'] == null
        ? null
        : User.fromJson(json['requester_user'] as Map<String, dynamic>),
    json['created_at'] as String,
    json['comment'] as String,
  );
}

Map<String, dynamic> _$PetitionToJson(Petition instance) => <String, dynamic>{
      'id': instance.id,
      'requested_card': instance.requestedCard,
      'requester_card': instance.requesterCard,
      'is_active': instance.isActive,
      'is_deleted': instance.isDeleted,
      'requester_user': instance.requesterUser,
      'requested_user': instance.requestedUser,
      'created_at': instance.date,
      'comment': instance.comment,
    };

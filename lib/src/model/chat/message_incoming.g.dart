// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_incoming.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageIncoming _$MessageIncomingFromJson(Map<String, dynamic> json) {
  return MessageIncoming(
    id: json['id'] as int,
    text: json['message'] as String,
    date: json['created_at'] as String,
    user: json['user'] == null
        ? null
        : User.fromJson(json['user'] as Map<String, dynamic>),
    hasBeenRead: Conversion.intToBool(json['has_been_read']),
  );
}

Map<String, dynamic> _$MessageIncomingToJson(MessageIncoming instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.text,
      'created_at': instance.date,
      'user': instance.user,
      'has_been_read': instance.hasBeenRead,
    };

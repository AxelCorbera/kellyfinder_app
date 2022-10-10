// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chat _$ChatFromJson(Map<String, dynamic> json) {
  return Chat(
    json['id'] as int,
    json['other_user'] == null
        ? null
        : User.fromJson(json['other_user'] as Map<String, dynamic>),
    (json['messages'] as List)
        ?.map((e) =>
            e == null ? null : Message.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['last_message'] == null
        ? null
        : Message.fromJson(json['last_message'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ChatToJson(Chat instance) => <String, dynamic>{
      'id': instance.id,
      'other_user': instance.contact,
      'messages': instance.messages,
      'last_message': instance.lastMessage,
    };

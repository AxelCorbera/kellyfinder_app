// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_outgoing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageOutgoing _$MessageOutgoingFromJson(Map<String, dynamic> json) {
  return MessageOutgoing(
    id: json['id'] as int,
    text: json['message'] as String,
    date: json['created_at'] as String,
    user: json['user'] == null
        ? null
        : User.fromJson(json['user'] as Map<String, dynamic>),
    status:
        _$enumDecodeNullable(_$MessageOutgoingStatusEnumMap, json['status']),
    hasBeenRead: Conversion.intToBool(json['has_been_read']),
  );
}

Map<String, dynamic> _$MessageOutgoingToJson(MessageOutgoing instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.text,
      'created_at': instance.date,
      'user': instance.user,
      'has_been_read': instance.hasBeenRead,
      'status': _$MessageOutgoingStatusEnumMap[instance.status],
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$MessageOutgoingStatusEnumMap = {
  MessageOutgoingStatus.NEW: 'NEW',
  MessageOutgoingStatus.SENT: 'SENT',
  MessageOutgoingStatus.FAILED: 'FAILED',
};

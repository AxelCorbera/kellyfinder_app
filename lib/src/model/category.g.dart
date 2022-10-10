// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) {
  return Category(
    json['id'] as int,
    json['name'] as String,
    Conversion.stringToColor(json['color']),
    json['pic'] as String,
    json['parent'] == null
        ? null
        : Category.fromJson(json['parent'] as Map<String, dynamic>),
    Conversion.intToBool(json['has_sons']),
    json['type'] as String,
    json['header_pic'] as String,
    json['description'] as String,
    Conversion.intToBool(json['can_advertise']),
    json['sector_pic'] as String,
  );
}

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'color': Conversion.colorToString(instance.color),
      'pic': instance.image,
      'header_pic': instance.header,
      'parent': Conversion.objectToJson(instance.parentCategory),
      'has_sons': instance.hasChild,
      'type': instance.type,
      'description': instance.description,
      'can_advertise': instance.canAdvertise,
      'sector_pic': instance.sector,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'street.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Street _$StreetFromJson(Map<String, dynamic> json) {
  return Street(
    json['id'] as int,
    json['name'] as String,
    json['district_id'] as String,
  );
}

Map<String, dynamic> _$StreetToJson(Street instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'district_id': instance.district_id,
    };

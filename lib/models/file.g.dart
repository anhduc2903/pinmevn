// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

File _$FileFromJson(Map<String, dynamic> json) {
  return File(
    json['id'] as int,
    json['name'] as String,
    json['type'] as String,
    (json['size'] as num)?.toDouble(),
    json['url'] as String,
    json['url_thumbnail_file'] as String,
    json['create_time'] as int,
    json['game_pin'] as String,
    json['advertising_id'] as int,
  );
}

Map<String, dynamic> _$FileToJson(File instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'size': instance.size,
      'url': instance.url,
      'url_thumbnail_file': instance.url_thumbnail_file,
      'create_time': instance.create_time,
      'game_pin': instance.game_pin,
      'advertising_id': instance.advertising_id,
    };

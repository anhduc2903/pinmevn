// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Device _$DeviceFromJson(Map<String, dynamic> json) {
  return Device(
    id: json['id'] as int,
    name: json['name'] as String,
    serial_id: json['serial_id'] as String,
    width: json['width'] as String,
    height: json['height'] as String,
    latitude: json['latitude'] as String,
    longtitude: json['longtitude'] as String,
    code: json['code'] as String,
    location_id: json['location_id'] as String,
    created_by_user_id: json['created_by_user_id'] as String,
  );
}

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'serial_id': instance.serial_id,
      'width': instance.width,
      'height': instance.height,
      'latitude': instance.latitude,
      'longtitude': instance.longtitude,
      'code': instance.code,
      'location_id': instance.location_id,
      'created_by_user_id': instance.created_by_user_id,
    };

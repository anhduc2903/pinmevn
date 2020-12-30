import 'package:json_annotation/json_annotation.dart';

part 'device.g.dart';

@JsonSerializable()
class Device {
  final int id;
  final String name;
  final String serial_id;
  final String width;
  final String height;
  final String latitude;
  final String longtitude;
  final String code;
  final String location_id;
  final String created_by_user_id;

  Device({
    this.id,
    this.name,
    this.serial_id,
    this.width,
    this.height,
    this.latitude,
    this.longtitude,
    this.code,
    this.location_id,
    this.created_by_user_id,
  });

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);
}

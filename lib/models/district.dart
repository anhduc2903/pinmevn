import 'package:json_annotation/json_annotation.dart';

part 'district.g.dart';

@JsonSerializable()
class District {
  final int id;
  final String name;
  final String city_id;

  District(this.id, this.name, this.city_id);

  factory District.fromJson(Map<String, dynamic> json) => _$DistrictFromJson(json);
}

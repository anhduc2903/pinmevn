import 'package:json_annotation/json_annotation.dart';

part 'city.g.dart';

@JsonSerializable()
class City {
  final int id;
  final String name;
  final String country_id;

  City(this.id, this.name, this.country_id);

  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);
}

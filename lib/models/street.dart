import 'package:json_annotation/json_annotation.dart';

part 'street.g.dart';

@JsonSerializable()
class Street {
  final int id;
  final String name;
  final String district_id;

  Street(this.id, this.name, this.district_id);

  factory Street.fromJson(Map<String, dynamic> json) => Street.fromJson(json);
}

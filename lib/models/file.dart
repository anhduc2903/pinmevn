import 'package:json_annotation/json_annotation.dart';

part 'file.g.dart';

@JsonSerializable()
class File {
  final int id;
  final String name;
  final String type;
  final double size;
  final String url;
  final String url_thumbnail_file;
  final int create_time;
  final String game_pin;
  final int advertising_id;

  File(
    this.id,
    this.name,
    this.type,
    this.size,
    this.url,
    this.url_thumbnail_file,
    this.create_time,
    this.game_pin,
    this.advertising_id,
  );

  factory File.fromJson(Map<String, dynamic> json) => _$FileFromJson(json);
}

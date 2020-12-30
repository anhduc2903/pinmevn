import 'package:json_annotation/json_annotation.dart';

part 'game.g.dart';

@JsonSerializable()
class Game {
  final int id;
  final String game_id;
  final String game_pin;
  final int enable;
  final String game_type;
  final String instance_id;
  final int total_question;
  final int user_advertiser_id;
  final int user_publisher_id;

  Game(
    this.id,
    this.game_id,
    this.game_pin,
    this.enable,
    this.game_type,
    this.instance_id,
    this.total_question,
    this.user_advertiser_id,
    this.user_publisher_id,
  );

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
}

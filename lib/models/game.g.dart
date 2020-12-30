// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Game _$GameFromJson(Map<String, dynamic> json) {
  return Game(
    json['id'] as int,
    json['game_id'] as String,
    json['game_pin'] as String,
    json['enable'] as int,
    json['game_type'] as String,
    json['instance_id'] as String,
    json['total_question'] as int,
    json['user_advertiser_id'] as int,
    json['user_publisher_id'] as int,
  );
}

Map<String, dynamic> _$GameToJson(Game instance) => <String, dynamic>{
      'id': instance.id,
      'game_id': instance.game_id,
      'game_pin': instance.game_pin,
      'enable': instance.enable,
      'game_type': instance.game_type,
      'instance_id': instance.instance_id,
      'total_question': instance.total_question,
      'user_advertiser_id': instance.user_advertiser_id,
      'user_publisher_id': instance.user_publisher_id,
    };

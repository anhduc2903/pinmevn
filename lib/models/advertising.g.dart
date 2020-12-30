// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advertising.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Advertising _$AdvertisingFromJson(Map<String, dynamic> json) {
  return Advertising(
    json['id'] as int,
    json['name'] as String,
    json['city'] as String,
    json['start_time'] as String,
    json['end_time'] as String,
    json['start_date'] as String,
    json['create_time'] as int,
    json['update_time'] as int,
    (json['amount'] as num)?.toDouble(),
    json['audience_id'] as int,
    json['user_advertiser_id'] as int,
    (json['files'] as List)
        ?.map(
            (e) => e == null ? null : File.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    (json['schedules'] as List)
        ?.map((e) =>
            e == null ? null : Schedule.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    (json['games'] as List)
        ?.map(
            (e) => e == null ? null : Game.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$AdvertisingToJson(Advertising instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'city': instance.city,
      'start_time': instance.start_time,
      'end_time': instance.end_time,
      'start_date': instance.start_date,
      'create_time': instance.create_time,
      'update_time': instance.update_time,
      'amount': instance.amount,
      'audience_id': instance.audience_id,
      'user_advertiser_id': instance.user_advertiser_id,
      'files': instance.files,
      'schedules': instance.schedules,
      'games': instance.games,
    };

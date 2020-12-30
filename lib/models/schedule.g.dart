// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Schedule _$ScheduleFromJson(Map<String, dynamic> json) {
  return Schedule(
    json['id'] as int,
    json['start_time'] as String,
    json['end_time'] as String,
    json['date'] as String,
    json['advertising_id'] as int,
    json['start_date'] as String,
    json['end_date'] as String,
  );
}

Map<String, dynamic> _$ScheduleToJson(Schedule instance) => <String, dynamic>{
      'id': instance.id,
      'start_time': instance.start_time,
      'end_time': instance.end_time,
      'date': instance.date,
      'advertising_id': instance.advertising_id,
      'start_date': instance.start_date,
      'end_date': instance.end_date,
    };

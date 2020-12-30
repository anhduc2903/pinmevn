import 'package:json_annotation/json_annotation.dart';

part 'schedule.g.dart';

@JsonSerializable()
class Schedule {
  final int id;
  final String start_time;
  final String end_time;
  final String date;
  final int advertising_id;
  final String start_date;
  final String end_date;

  Schedule(
    this.id,
    this.start_time,
    this.end_time,
    this.date,
    this.advertising_id,
    this.start_date,
    this.end_date,
  );

  factory Schedule.fromJson(Map<String, dynamic> json) => _$ScheduleFromJson(json);
}

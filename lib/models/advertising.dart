import 'package:json_annotation/json_annotation.dart';

import './schedule.dart';
import './file.dart';
import './game.dart';

part 'advertising.g.dart';

@JsonSerializable()
class Advertising {
  final int id;
  final String name;
  final String city;
  final String start_time;
  final String end_time;
  final String start_date;
  final int create_time;
  final int update_time;
  final double amount;
  final int audience_id;
  final int user_advertiser_id;
  final List<File> files;
  final List<Schedule> schedules;
  final List<Game> games;

  Advertising(
    this.id,
    this.name,
    this.city,
    this.start_time,
    this.end_time,
    this.start_date,
    this.create_time,
    this.update_time,
    this.amount,
    this.audience_id,
    this.user_advertiser_id,
    this.files,
    this.schedules,
    this.games
  );

  factory Advertising.fromJson(Map<String, dynamic> json) => _$AdvertisingFromJson(json);
}

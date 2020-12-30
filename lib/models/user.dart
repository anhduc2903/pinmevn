import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String email;
  final String password;
  final String password_confirmation;
  final String login_code;
  final String avatar;
  final String full_name;
  final String phone;
  final String create_time;
  final String update_time;
  final String access_token;

  User({
    this.id,
    this.email,
    this.password,
    this.password_confirmation,
    this.login_code,
    this.avatar,
    this.full_name,
    this.phone,
    this.create_time,
    this.update_time,
    this.access_token,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

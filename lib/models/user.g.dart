// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    id: json['id'] as int,
    email: json['email'] as String,
    password: json['password'] as String,
    password_confirmation: json['password_confirmation'] as String,
    login_code: json['login_code'] as String,
    avatar: json['avatar'] as String,
    full_name: json['full_name'] as String,
    phone: json['phone'] as String,
    create_time: json['create_time'] as String,
    update_time: json['update_time'] as String,
    access_token: json['access_token'] as String,
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'password': instance.password,
      'password_confirmation': instance.password_confirmation,
      'login_code': instance.login_code,
      'avatar': instance.avatar,
      'full_name': instance.full_name,
      'phone': instance.phone,
      'create_time': instance.create_time,
      'update_time': instance.update_time,
      'access_token': instance.access_token,
    };

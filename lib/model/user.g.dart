// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User()
    ..id = json['id'] as int
    ..avatar = json['avatar'] as String
    ..email = json['email'] as String
    ..name = json['name'] as String
    ..age = json['age'] as int ?? 0
    ..gender = json['gender'] as int ?? 1;
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'avatar': instance.avatar,
      'email': instance.email,
      'name': instance.name,
      'age': instance.age,
      'gender': instance.gender
    };

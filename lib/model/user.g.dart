// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'email']);
  return User()
    ..id = json['id'] as int ?? 0
    ..avatar = json['avatar'] as String ?? ''
    ..email = json['email'] as String
    ..name = json['name'] as String ?? ''
    ..age = json['age'] as int ?? 0
    ..gender = json['gender'] as int ?? 0;
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'avatar': instance.avatar,
      'email': instance.email,
      'name': instance.name,
      'age': instance.age,
      'gender': instance.gender
    };

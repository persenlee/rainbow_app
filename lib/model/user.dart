import 'package:json_annotation/json_annotation.dart';
part 'user.g.dart';

@JsonSerializable()
class User {
  User();
  @JsonKey(defaultValue: 0)
  int id;
  String avatar;
  String email;
  String name;
  @JsonKey(defaultValue: 0)
  int age;
  @JsonKey(defaultValue: 1)
  int gender;
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
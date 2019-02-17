import 'package:json_annotation/json_annotation.dart';
part 'user.g.dart';

@JsonSerializable()
class User {
  User();
  @JsonKey(defaultValue: 0,required: true)
  int id;
  @JsonKey(defaultValue: '')
  String avatar;
  @JsonKey(required: true)
  String email;
  @JsonKey(defaultValue: '')
  String name;
  @JsonKey(defaultValue: 0)
  int age;
  @JsonKey(defaultValue: 0)
  int gender;
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
import 'package:json_annotation/json_annotation.dart';
part 'user.g.dart';

@JsonSerializable()
class User {
  User({
    this.id = 0,
    this.avatar = '',
    this.email = '',
    this.userName = '',
  }
  );
  int id;
  String avatar;
  String email;
  String userName;
  int age;
  int gender;
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
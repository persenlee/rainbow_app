import 'package:json_annotation/json_annotation.dart';
//use [flutter packages pub run build_runner build] command to generate 
part 'feed.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Feed{
  Feed();
  int id;
  @JsonKey(defaultValue: '')
  String title;
  @JsonKey(defaultValue: '')
  String src;
  @JsonKey(defaultValue: '')
  String thumbSrc;
  @JsonKey(defaultValue: 0)
  int likeCount;
  @JsonKey(name: 'favorite',defaultValue: false)
  bool like;
  List<Tag> tags;
  factory Feed.fromJson(Map<String, dynamic> json) => _$FeedFromJson(json);
  Map<String, dynamic> toJson() => _$FeedToJson(this);
}

@JsonSerializable()
class Tag {
  Tag();
  int id;
  String name;
  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
  Map<String, dynamic> toJson() => _$TagToJson(this);
}
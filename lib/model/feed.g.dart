// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Feed _$FeedFromJson(Map<String, dynamic> json) {
  return Feed()
    ..id = json['id'] as int
    ..title = json['title'] as String ?? ''
    ..src = json['src'] as String ?? ''
    ..thumbSrc = json['thumb_src'] as String ?? ''
    ..likeCount = json['like_count'] as int ?? 0
    ..like = json['favorite'] as bool ?? false
    ..tags = (json['tags'] as List)
        ?.map((e) => e == null ? null : Tag.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$FeedToJson(Feed instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'src': instance.src,
      'thumb_src': instance.thumbSrc,
      'like_count': instance.likeCount,
      'favorite': instance.like,
      'tags': instance.tags
    };

Tag _$TagFromJson(Map<String, dynamic> json) {
  return Tag()
    ..id = json['id'] as int
    ..name = json['name'] as String;
}

Map<String, dynamic> _$TagToJson(Tag instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

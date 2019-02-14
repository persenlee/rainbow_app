import 'package:flutter/material.dart';
import 'package:Shrine/api/base_api.dart';
import 'package:Shrine/api/feed_api.dart';
import 'package:Shrine/model/feed.dart';
import 'user_storage.dart';
import 'dart:math';

typedef VoidSuccessCallback = void Function();
typedef VoidFailureCallback = void Function();

class Action {
  static like(BuildContext context,Feed feed,VoidSuccessCallback successCallBack,VoidFailureCallback failCallback){
    UserStorage.getInstance().readUser().then((user) {
      if (user != null && user.id > 0) {
        FeedAPI.like(feed.id, !feed.like).then((response) {
          if (response.code == WrapCode.Ok) {
            feed.like = !feed.like;
            int count = (feed.like ? feed.likeCount + 1 : feed.likeCount - 1);
            feed.likeCount = max(count, 0);
            successCallBack();
          } else {
            failCallback();
          }
        });
      } else {
        Navigator.of(context).pushNamed('/login');
      }
    });
  }
}
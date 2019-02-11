import 'dart:convert';
import '../model/feed.dart';
import './base_api.dart';

class FeedAPI {
  static getFeeds(int page, int perPage) async {
    const url = '/feed/feeds';
    try {
      Map params = {'page':page.toString()
      ,'perPage':perPage.toString()};
      var response = await BaseAPI.requestUrl(url, HttpMethod.Get, params);
      if (response.code == WrapCode.Ok) {
        List<int> bodyBytes = response.response.bodyBytes;
        List list = json.decode(utf8.decode(bodyBytes));
        List<Feed> feedList = new List();
        for (var map in list) {
          String tagStr = map['tags'];
          if (tagStr == '') {
            map['tags'] = null;
          } else {
            map['tags'] = json.decode(tagStr);
          }
          Feed feed = Feed.fromJson(map);
          feedList.add(feed);
        }
        response.result = feedList;
      }
      return response;
    } catch (e) {
      print(e.messge);
    }
  }

  static like(int feedId,bool like) async {
    const url = '/feed/like';
    try {
      Map params = {'id':feedId,'like':like};
      var response = await BaseAPI.requestUrl(url, HttpMethod.Post, params);
      return response;
    } catch (e) {
    }
  }
}

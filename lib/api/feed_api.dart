import 'dart:convert';
import '../model/feed.dart';
import './base_api.dart';

class FeedAPI {
  static getFeeds(int page, int perPage) async {
    const url = '/feed/feeds';
    try {
      Map params = {'page':page.toString()
      ,'per_page':perPage.toString()};
      var response = await BaseAPI.requestUrl(url, HttpMethod.Get, params);
      if (response.code == WrapCode.Ok) {
        List list = response.response.data;
        List<Feed> feedList = new List();
        for (var map in list) {
          String tagStr = map['tags'];
          if (tagStr == '') {
            map['tags'] = null;
          } else {
            List tags = List();
            for (int t in json.decode(tagStr)){
              tags.add({'id' : t,'name' : ''});
            }
            map['tags'] = tags;
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

  static report(int feedId,int reportId,String reportReason) async{
    const url = '/feed/report';
    try {
      Map params = {'id':feedId,'reportId':reportId};
      if(reportReason != null && reportReason.trim().length > 0) {
        params['report_reason'] = reportReason;
      }
      var response = await BaseAPI.requestUrl(url, HttpMethod.Post, params);
      return response;
    } catch (e) {
    }
  }

  static tag(int feedId,int tagId) async {
    const url = '/feed/tag';
    try {
      Map params = {'id':feedId,'tag_id':tagId};
      var response = await BaseAPI.requestUrl(url, HttpMethod.Post, params);
      return response;
    } catch (e) {
    }
  }
}

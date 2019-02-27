import 'dart:convert';
import '../model/feed.dart';
import './base_api.dart';
import 'package:Rainbow/supplemental/config_storage.dart';

class FeedAPI extends BaseAPI{
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
          if (tagStr ==null || tagStr.trim().length == 0) {
            map['tags'] = null;
          } else {
            List tags = List();
            for (int t in json.decode(tagStr)){
              ConfigStorage storage =await ConfigStorage.getInstance();
              String name = storage.tagNameById(t);
              name =name ==null ? 'other' : name; 
              tags.add({'id' : t,'name' : name});
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
      throw e;
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
      Map params = {'id':feedId,'report_id':reportId};
      if(reportReason != null && reportReason.trim().length > 0) {
        params['report_reason'] = reportReason;
      }
      var response = await BaseAPI.requestUrl(url, HttpMethod.Post, params);
      return response;
    } catch (e) {
    }
  }

  static tags(int feedId,List<Tag> tags) async {
    const url = '/feed/tags';
    if (tags == null || feedId ==null) {
      WrapResponse response =WrapResponse();
      response.code = WrapCode.Fail;
      response.msg = 'feedId or tags is null';
      return response;
    }
    try {
      List tagIds =tags.map((Tag tag){
        return tag.id;
      }).toList();

      String tagIdsJsonStr = json.encode(tagIds);
      Map params = {'id':feedId,'tag_ids':tagIdsJsonStr};
      var response = await BaseAPI.requestUrl(url, HttpMethod.Post, params);
      return response;
    } catch (e) {
    }
  }
}

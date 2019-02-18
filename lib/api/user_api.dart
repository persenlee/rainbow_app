import 'dart:convert';
import '../model/feed.dart';
import './base_api.dart';
import 'package:Rainbow/model/user.dart';

class UserAPI extends BaseAPI{
  static login(String email, String password) async {
    const url = '/user/login';
    try {
      Map params = {'email': email, 'password': password};
      var response = await BaseAPI.requestUrl(url, HttpMethod.Post, params);
      if (response.code == WrapCode.Fail) {
        response.msg = 'email or password error';
      } else {
        User user = User.fromJson(response.response.data);
        response.result = user;
      }
      return response;
    } catch (e) {
      print(e.messge);
    }
  }

  static register(String email, String password) async {
    const url = '/user/signup';
    try {
      Map params = {'email': email, 'password': password};
      var response = await BaseAPI.requestUrl(url, HttpMethod.Post, params);
      if (response.code == WrapCode.Fail) {
        response.msg = 'email or password error';
      }
      return response;
    } catch (e) {
      print(e.messge);
    }
  }

  static profile() async {
    const url = '/user/profile';
    try {
      var response = await BaseAPI.requestUrl(url, HttpMethod.Get, null);
      if (response.code == WrapCode.Ok) {
        User user = User.fromJson(response.response.data);
        response.result = user;
      }
      return response;
    } catch (e) {
    }
  }

  static editProfile(User user) async {
    if (user ==null) {
      return null;
    }
    const url = '/user/profile';
    try {
      Map params = {};
      if(user.name != null)
        params['name'] = user.name;
      if(user.avatar != null)
        params['avatar'] = user.avatar;
      if(user.age != null)
        params['age'] = user.age;
      if(user.gender != null)
        params['gender'] = user.gender;
      var response = await BaseAPI.requestUrl(url, HttpMethod.Post, params);
      return response;
    } catch (e) {
    }
  }

  static sendMailCode(String email) async {
    const url = '/user/mail_code';
    try {
      Map params = {'email' : email};
      var response = await BaseAPI.requestUrl(url, HttpMethod.Post, params);
      return response;
    } catch (e) {
    }
  }

  static emailUsed(String email) async {
    const url = '/user/email_used';
    try {
      Map params = {'email' : email};
      var response = await BaseAPI.requestUrl(url, HttpMethod.Post, params);
      response.result = response.response.data['used'];
      return response;
    } catch (e) {
    }
  }

  static likes(int page, int perPage) async{
    const url = '/user/likes';
    try {
      Map params = {'page':page.toString()
      ,'per_page':perPage.toString()};
      var response = await BaseAPI.requestUrl(url, HttpMethod.Get, params);
      if (response.code == WrapCode.Ok) {
        if (response.response.data == '') {
          return response;
        }
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
}

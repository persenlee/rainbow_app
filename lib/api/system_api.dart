import 'base_api.dart';
import 'package:Rainbow/model/feed.dart';

class SystemAPI{
  static config() async {
    const url = '/system/config';
    try {
      var response = await BaseAPI.requestUrl(url, HttpMethod.Get, null);
      String configStr =  response.response.toString();
      response.result = configStr;
      return response;
    } catch (e) {
    }
  }
}
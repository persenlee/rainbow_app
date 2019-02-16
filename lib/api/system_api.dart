import 'base_api.dart';

class SystemAPI extends BaseAPI{
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
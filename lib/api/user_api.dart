import './base_api.dart';

class LoginAPI {
  static login(String email, String password) async {
    const url = '/user/login';
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
}

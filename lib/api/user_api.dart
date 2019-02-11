import './base_api.dart';

class LoginAPI {
  static login(String email, String password) async {
    const url = 'http://192.168.3.5:8000/user/login';
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
    const url = 'http://192.168.3.5:8000/user/signup';
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

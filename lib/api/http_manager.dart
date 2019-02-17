import 'package:dio/dio.dart';
import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:Rainbow/supplemental/user_storage.dart';

class HttpManager {
  static HttpManager _instance;
  final httpClient = new Dio();
  final baseUrl = /*'http://192.168.0.200:8000';*/ 'http://192.168.3.5:8000';
  CookieJar cj;

  HttpManager() {
    httpClient.options.baseUrl = baseUrl;
    httpClient.options.contentType =
        ContentType.parse("application/x-www-form-urlencoded");
    httpClient.options.connectTimeout = 3000; //5s
    httpClient.options.receiveTimeout = 3000;
    httpClient.interceptors.add(LogInterceptor(responseBody: true));
  }

  static sharedInstance() async {
    if (_instance == null) {
      _instance = HttpManager();
      await _instance._addCookieManager();
      _instance._listenSessionExpire();
    }
    return _instance;
  }

  _addCookieManager() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    cj = new PersistCookieJar(appDocPath);
    httpClient.interceptors.add(CookieManager(cj));
    return true;
  }

  _listenSessionExpire() {
    Interceptor interceptor = InterceptorsWrapper(onRequest: (Options options) {
      Uri uri = Uri.parse(baseUrl);
      List<Cookie> cookies = cj.loadForRequest(uri);
      bool foundSession = false;
      bool expried = false;
      for (Cookie cookie in cookies) {
        if (cookie.name == 'sessionid') {
          foundSession = true;
          if (cookie.expires.compareTo(DateTime.now()) <= 0) {
            cookies.remove(cookie);
            expried = true;
          }
          break;
        }
      }
      if (!foundSession || expried) {
        UserStorage.getInstance().deleteUser();
      }
      return options;
    });
    httpClient.interceptors.add(interceptor);
  }

  get(String url, Map query) async {
    try {
      Response response;
      if (query == null) {
        response = await httpClient.get(url);
      } else {
        Map<String, dynamic> queryParams = new Map<String, dynamic>.from(query);
        response = await httpClient.get(url, queryParameters: queryParams);
      }
      return response;
    } catch (e) {
      throw e;
    }
  }

  post(String url, dynamic data) async {
    try {
      var response = await httpClient.post(url, data: data);
      return response;
    } catch (e) {
      throw e;
    }
  }
}

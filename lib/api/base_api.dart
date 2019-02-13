import 'package:dio/dio.dart';
import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';

enum WrapCode {
  Ok,
  Fail,
}

class WrapResponse {
  WrapCode code;
  String msg;
  var result;
  Response response;
}

enum HttpMethod {
  Get,
  Post,
}

class BaseAPI {
  static requestUrl(String url, HttpMethod method, Map params) async {
    var httpClient = new Dio();
    httpClient.options.baseUrl = 'http://192.168.3.5:8000';
    httpClient.options.contentType = ContentType.parse("application/x-www-form-urlencoded");
    httpClient.options.connectTimeout = 3000; //5s
    httpClient.options.receiveTimeout = 3000;
    httpClient.interceptors.add(LogInterceptor(responseBody: false));
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    CookieJar cj=new PersistCookieJar(appDocPath);
    httpClient.interceptors.add(CookieManager(cj));
    try {
      var response;
      if (method == HttpMethod.Get) {
        Map<String, dynamic> queryParams = new Map<String, dynamic>.from(params);
        response = await httpClient.get(url,queryParameters: queryParams);
      }
      if (method == HttpMethod.Post) {
        response = await httpClient.post(url, data: params);
      }
      WrapResponse wr = WrapResponse();
      wr.response = response;
      wr.code =
          response.statusCode == HttpStatus.ok ? WrapCode.Ok : WrapCode.Fail;
      return wr;
    } catch (e) {
      throw e;
    }
  }
}

import 'package:dio/dio.dart';
import 'dart:io';
import 'http_manager.dart';

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
    HttpManager manager = await HttpManager.sharedInstance();
    try {
      var response;
      if (method == HttpMethod.Get) {
          response = await manager.get(url, params);
      }
      if (method == HttpMethod.Post) {
        response = await manager.post(url, params);
      }
      WrapResponse wr = WrapResponse();
      wr.response = response;
      wr.code =
          response.statusCode == HttpStatus.ok ? WrapCode.Ok : WrapCode.Fail;

      if (wr.code == WrapCode.Fail) {
        wr.msg = 'requst error,please try again';
      }
      return wr;
    } on DioError catch (e) {
      WrapResponse wr = WrapResponse();
      wr.response = e.response;
      wr.code = WrapCode.Fail;
       wr.msg = 'requst error,please try again';
      return wr;
    } catch (e) {
      throw e;
    }
  }
}

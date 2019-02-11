import 'package:http/http.dart' as http;
import 'dart:io';

enum WrapCode {
  Ok,
  Fail,
}

class WrapResponse {
  WrapCode code;
  String msg;
  var result;
  http.Response response;
}

enum HttpMethod {
  Get,
  Post,
}

class BaseAPI {
  static requestUrl(String url, HttpMethod method, Map params) async {
    var httpClient = new http.Client();
    try {
      var response;

      if (method == HttpMethod.Get) {
        Map<String,String> query = new Map<String,String>.from(params);
        var uri = Uri.http('192.168.3.5:8000', url, query);
        response = await httpClient.get(uri.toString());
      }
      if (method == HttpMethod.Post) {
        var uri = Uri.http('192.168.3.5:8000', url);
        response = await httpClient.post(uri.toString(), body: params);
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

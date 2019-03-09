import 'package:dio/dio.dart';
import 'dart:io';
import 'http_manager.dart';
import 'package:Rainbow/supplemental/user_storage.dart';

final String upload_base_url = 'http://pnl34ar1f.bkt.clouddn.com';

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
          response.statusCode == 200 ? WrapCode.Ok : WrapCode.Fail;
      if (response.statusCode == 401) {
        //cookie expired
        manager.deleteCookie();
        UserStorage.getInstance().deleteUser();
      }
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

  static uploadFile(File file, ProgressCallback progressCallback) async {
    HttpManager manager = await HttpManager.sharedInstance();
    try {
      var response = await manager.uploadResource(file.path, progressCallback);
      WrapResponse wr = WrapResponse();
      wr.response = response;
      Map result = response.data;
      String key = result['key'];
      // String hash = result['hash'];
      String fileUrl = upload_base_url + '/' + key;
      wr.result = fileUrl;
      wr.code =
          response.statusCode == 200 ? WrapCode.Ok : WrapCode.Fail;
      if (wr.code == WrapCode.Fail) {
        wr.msg = 'upload failed';
      }
      return wr;
    } on DioError catch (e) {
      WrapResponse wr = WrapResponse();
      wr.response = e.response;
      wr.code = WrapCode.Fail;
      wr.msg = 'upload failed';
      return wr;
    } catch (e) {}
  }
}

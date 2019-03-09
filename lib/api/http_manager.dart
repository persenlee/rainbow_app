import 'package:dio/dio.dart';
import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:Rainbow/supplemental/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:Rainbow/supplemental/util.dart';
import 'package:flutter/services.dart';

typedef PLProgressCallback = Function(int received, int total);

class HttpManager {
  static HttpManager _instance;
  final httpClient = new Dio();
  String baseUrl = Util.baseUrlForMode(BaseUrlMode.Test);
  PersistCookieJar cj;
  SharedPreferences prefs;
  String _uploadToken;

  
  HttpManager() {
    httpClient.options.baseUrl = baseUrl;
    httpClient.options.contentType =
        ContentType.parse("application/x-www-form-urlencoded");
    httpClient.options.connectTimeout = 5000; //5s
    httpClient.options.receiveTimeout = 5000;
    httpClient.interceptors.add(LogInterceptor(responseBody: true)); 
  }

  static sharedInstance() async {
    if (_instance == null) {
      _instance = HttpManager();
      _instance.prefs = await SharedPreferences.getInstance();
      String urlMode = _instance.prefs.getString('default_url_mode');
      if (urlMode == null) {
        urlMode =BaseUrlMode.Release.toString();
      }
      BaseUrlMode mode = Util.urlModeFromString(urlMode);
      String storedBaseUrl = Util.baseUrlForMode(mode);
      _instance.baseUrl = storedBaseUrl;
      _instance.httpClient.options.baseUrl = storedBaseUrl;
      if (mode ==BaseUrlMode.Test ||
          mode ==BaseUrlMode.Release) {
        await _instance._addSSLCertVerify();
      }
      await _instance._addCookieManager();
      _instance._listenSessionExpire();
    }
    return _instance;
  }

  _addSSLCertVerify() async{
    final String pemStr = await rootBundle.loadString('assets/server.pem');
      (httpClient.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate  = (client) {
        client.badCertificateCallback=(X509Certificate cert, String host, int port){
          if(cert.pem==pemStr){ // Verify the certificate
              return true; 
          }
          return false;
        };
      };
  }


  _removeSSLCertVerify() {
    (httpClient.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =null;
  }


  resetUrlMode(BaseUrlMode mode) async{
    String baseUrl = Util.baseUrlForMode(mode);
    bool result = await prefs.setString('default_url_mode', mode.toString());
    if (result) {
      this.baseUrl =baseUrl;
      httpClient.options.baseUrl = baseUrl;
      if (mode ==BaseUrlMode.Test ||
          mode ==BaseUrlMode.Release) {
        await _addSSLCertVerify();
      } else {
        _removeSSLCertVerify();
      }
    }
    return result;
  }

  deleteCookie() {
    cj.deleteAll();
  }

  _addCookieManager() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    cj = new PersistCookieJar(dir:appDocPath);
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

  loadResource(String url) async {
    try {
      Response response = await Dio().get(url);
      return response.data;
    } catch (e) {
      throw e;
    }
  }

  _getUploadToken() async {
    try {
      Response response = await get('/system/upload_token', null);
      if (response.statusCode == 200) {
        return response.data['token'];
      } else {
        return null;
      }
    } catch (e) {}
  }

  uploadResource(String filePath, ProgressCallback progressCallback) async {
    try {
      var dio = Dio();
      dio.options.baseUrl = "https://upload.qiniup.com";
      dio.interceptors.add(LogInterceptor(responseBody: true));
      // var uuid = new Uuid();
      // var fileName = uuid.v4();
      if (_uploadToken == null) {
        _uploadToken = await _getUploadToken();
      }
      if (_uploadToken != null) {
        FormData formData = new FormData.from({
          // "resource_key" : fileName,
          "token": _uploadToken,
          "file": new UploadFileInfo(new File(filePath), "upload")
        });
        Response response = await dio.post("",
            data: formData, onSendProgress: progressCallback);
        return response;
      } else {
       throw Exception('invlidate upload token');
      }
    } catch (e) {
      throw e;
    }
  }
}

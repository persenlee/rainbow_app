import 'package:dio/dio.dart';
import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:Rainbow/supplemental/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

typedef ProgressCallback = Function(int received, int total);

class HttpManager {
  static HttpManager _instance;
  final httpClient = new Dio();
  String baseUrl = 'http://192.168.3.5:8000';
  CookieJar cj;
  SharedPreferences prefs;
  String _uploadToken;

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
      _instance.prefs = await SharedPreferences.getInstance();
      String storedBaseUrl = _instance.prefs.getString('base_url');
      if (storedBaseUrl != null) {
        _instance.baseUrl = storedBaseUrl;
        _instance.httpClient.options.baseUrl = storedBaseUrl;
      }
      await _instance._addCookieManager();
      _instance._listenSessionExpire();
    }
    return _instance;
  }

  resetBaseUrl(String baseUrl) async {
    bool result = await prefs.setString('base_url', baseUrl);
    if (result) {
      this.baseUrl = baseUrl;
      httpClient.options.baseUrl = baseUrl;
    }
    return result;
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
      if (response.statusCode == HttpStatus.ok) {
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
            data: formData, onUploadProgress: progressCallback);
        return response;
      } else {
       throw Exception('invlidate upload token');
      }
    } catch (e) {
      throw e;
    }
  }
}

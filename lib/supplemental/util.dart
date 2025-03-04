import 'dart:core';
import 'package:sensors/sensors.dart';
import 'package:native_share/native_share.dart';
import 'package:Rainbow/api/http_manager.dart';
import 'package:path/path.dart' as p;

enum BuildMode { release, profile, debug }

enum BaseUrlMode {Local_Home,Local_Company,Develop,Test,Release}

typedef MotionShakeDetectCallback = void Function(bool);

class Util {
  static final MotionShakeDetector shakeDetector =MotionShakeDetector();
  
  static String baseUrlForMode(BaseUrlMode mode)
  {
    String baseUrl;
    switch (mode) {
      case BaseUrlMode.Local_Home:
        baseUrl = 'http://192.168.3.5:8000';
        break;
      case BaseUrlMode.Local_Company:
        baseUrl = 'http://192.168.0.200:8000';
        break;
      case BaseUrlMode.Develop:
        break;
      case BaseUrlMode.Test:
        baseUrl = 'https://test.rainbowplanet.club';
        break;
      case BaseUrlMode.Release:
        baseUrl = 'https://www.rainbowplanet.club';
        break;
      default:
    }
    return baseUrl;
  }

  static BaseUrlMode urlModeFromString(String modeStr)
  {
    BaseUrlMode  realMode;
    for (BaseUrlMode mode in BaseUrlMode.values) {
      if (mode.toString() ==modeStr) {
        realMode =mode;
        break;
      }
    }
    return realMode;
  }

  static Future<String> absoluteUrlForPath(String path) async{
    HttpManager manager = await HttpManager.sharedInstance();
    return p.join(manager.baseUrl,path);
  }

  static String sslPemForMode(BaseUrlMode mode){
    String pemStr ;
    switch (mode) {
      case BaseUrlMode.Test:
        pemStr = "";
        break;
      default:
    }
    return pemStr;
  }

  static String genderConvert(int gender) {
    String genderStr = 'Male';
    switch (gender) {
      case 0:
        genderStr = 'Male';
        break;
      case 1:
        genderStr = 'Femal';
        break;
      case 2:
        genderStr = 'Others';
        break;
      default:
    }
    return genderStr;
  }

  static BuildMode buildMode() {
    if (const bool.fromEnvironment('dart.vm.product')) {
      return BuildMode.release;
    } else {
      return BuildMode.debug;
    }
  }

  static listenMotionShake(MotionShakeDetectCallback callback){
    Util.shakeDetector.detectShake(callback);
  }

  static share(String title,String url,String image) {
    Map<String,dynamic> params =Map();
    if(title !=null && title.trim().length > 0) {
      params['title'] =title;
    }
    if(url !=null && url.trim().length > 0) {
      params['url'] =url;
    }
    if(image !=null && image.trim().length > 0) {
      params['image'] =image;
    }
    NativeShare.share(params);
  }
}



class MotionShakeDetector {
  static final int shakeTHRESHOLD = 1500;
  double lastX = 0, lastY = 0, lastZ = 0;
  int lastUpdate = 0;
  detectShake(MotionShakeDetectCallback callback) {
    accelerometerEvents.listen((AccelerometerEvent event) {
      int curTime = DateTime.now().millisecondsSinceEpoch;
      // only allow one update every 100ms.
      if ((curTime - lastUpdate) > 100) {
        int diffTime = (curTime - lastUpdate);
        lastUpdate = curTime;
        double x = event.x;
        double y = event.y;
        double z = event.x;

        double speed = (x + y + z - lastX - lastY - lastZ).abs() / diffTime * 10000;

        if (speed > shakeTHRESHOLD) {
          callback(true);
        }
        lastX = x;
        lastY = y;
        lastZ = z;
      }
      
    });
  }
}

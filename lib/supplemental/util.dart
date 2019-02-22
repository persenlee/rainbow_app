import 'dart:core';
import 'package:sensors/sensors.dart';

enum BuildMode { release, profile, debug }

enum BaseUrlMode {Local_Home,Local_Company,Develop,Release}

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
      case BaseUrlMode.Release:
        break;
      default:
    }
    return baseUrl;
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
}



class MotionShakeDetector {
  static final int SHAKE_THRESHOLD = 1500;
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

        if (speed > SHAKE_THRESHOLD) {
          callback(true);
        }
        lastX = x;
        lastY = y;
        lastZ = z;
      }
      
    });
  }
}
